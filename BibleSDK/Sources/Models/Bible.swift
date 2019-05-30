//
//  Bible.swift
//  BibleSDK
//
//  Created by Grigory Avdyushin on 09/05/2019.
//

public protocol BibleProtocol {
    var version: Version { get }
    var books: [Book] { get }
    func book(name: String) -> Book?
    func book(id: Book.BookId) -> Book?
    func verses(bookId: Book.BookId, chapters: IndexSet, verses: IndexSet) -> [Verse]
    func searchCount(_ string: String) -> Int
    func search(_ string: String, offset: Int, count: Int, surround: (String, String)?) -> [Verse]
    subscript(id: Book.BookId) -> Book? { get }
    subscript(name: String) -> Book? { get }
}

public struct BibleReference: Hashable, Comparable {
    public let version: Version
    public let reference: Verse.Reference

    public static func < (lhs: BibleReference, rhs: BibleReference) -> Bool {
//        return lhs.version.identifier.compare(rhs.version.identifier) == .orderedAscending &&
        return lhs.reference.book.id < rhs.reference.book.id
    }
}

extension BibleProtocol {
    func verses(bookId: Book.BookId, chapters: IndexSet = [], verses: IndexSet = []) -> [Verse] {
        return self.verses(bookId: bookId, chapters: chapters, verses: verses)
    }
}

class Bible: BibleProtocol {

    let version: Version
    let storage: Storage
    lazy var books = try! fetchAllBooks()

    init(version: Version, path: String) throws {
        self.version = version
        self.storage = try BaseSqliteStorage(filename: path)
    }

    func book(name: String) -> Book? {
        return books.first {
            $0.title.lowercased().hasPrefix(name.lowercased()) ||
            $0.alt.lowercased().hasPrefix(name.lowercased()) ||
            $0.abbr.lowercased().hasPrefix(name.lowercased())
        }
    }

    func book(id: Book.BookId) -> Book? {
        return books.first {
            $0.id == id
        }
    }

    subscript(id: Book.BookId) -> Book? {
        return book(id: id)
    }

    subscript(name: String) -> Book? {
        return book(name: name)
    }

    func verses(bookId: Book.BookId, chapters: IndexSet = [], verses: IndexSet = []) -> [Verse] {
        guard !chapters.isEmpty || !verses.isEmpty else {
            return self.verses(bookId: bookId)
        }

        guard !verses.isEmpty else {
            return self.verses(bookId: bookId, chapters: chapters)
        }

        guard chapters.count == 1, let chapter = chapters.first else {
            assertionFailure("Can't mix chapter set with verses set")
            return []
        }

        let verseSet = verses.map(String.init).joined(separator: ",")
        return fetchVerses(where: "book_id = \(bookId) AND chapter = \(chapter) AND verse IN (\(verseSet))")
    }

    func searchCount(_ string: String) -> Int {
        let string = string.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        let query =
        """
        SELECT
            COUNT(*)
        FROM
            \(version.identifier)_bible_index
        WHERE
            text
        MATCH
            '\(string)';
        """
        do {
            guard let row = try storage.fetch(query).first else {
                return 0
            }
            return row["COUNT(*)"] ?? 0
        } catch {
            return 0
        }
    }

    func search(_ string: String, offset: Int, count: Int, surround: (String, String)?) -> [Verse] {
        let string = string.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        let text: String
        if let (prefix, suffix) = surround {
            text = "highlight(\(version.identifier)_bible_index, 3, '\(prefix)', '\(suffix)') as text"
        } else {
            text = "text"
        }

        let query =
        """
        SELECT
            v.book_id, v.verse, v.chapter, \(text), b.book as book_name, b.alt as book_alt
        FROM
            \(version.identifier)_bible_index v
        LEFT OUTER JOIN \(version.identifier)_bible_books b on (v.book_id = b.id)
        WHERE
            text
        MATCH
            '\(string)'
        ORDER BY
            rank
        LIMIT
            \(offset), \(count);
        """
        do {
            return try storage.fetch(query).map(Verse.init)
        } catch {
            return []
        }
    }

    fileprivate func verses(bookId: Book.BookId, chapters: IndexSet) -> [Verse] {
        precondition(!chapters.isEmpty)

        let chapterSet = chapters.map(String.init).joined(separator: ",")
        return fetchVerses(where: "book_id = \(bookId) AND chapter IN (\(chapterSet))")
    }

    fileprivate func verses(bookId: Book.BookId) -> [Verse] {
        return fetchVerses(where: "book_id = \(bookId)")
    }

    fileprivate func fetchVerses(where condition: String) -> [Verse] {
        let query =
        """
        SELECT
            book_id, verse, chapter, text
        FROM
            \(version.identifier)_bible
        WHERE
            \(condition);
        """
        do {
            return try storage.fetch(query).map(Verse.init)
        } catch {
            debugPrint(error)
            return []
        }
    }

    fileprivate func fetchAllBooks() throws -> [Book] {
        let query =
        """
        SELECT
            \(version.identifier)_bible_books.id,
            \(version.identifier)_bible_books.idx,
            \(version.identifier)_bible_books.book AS title,
            \(version.identifier)_bible_books.alt,
            \(version.identifier)_bible_books.abbr,
            (SELECT
                COUNT(DISTINCT \(version.identifier)_bible.chapter)
            FROM \(version.identifier)_bible
            WHERE \(version.identifier)_bible.book_id = \(version.identifier)_bible_books.id) AS chapters
        FROM \(version.identifier)_bible_books;
        """

        return try storage.fetch(query).map(Book.init)
    }
}
