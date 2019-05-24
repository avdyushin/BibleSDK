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
    func search(_ string: String, offset: Int, count: Int) -> [Verse]
    subscript(id: Book.BookId) -> Book? { get }
    subscript(name: String) -> Book? { get }
}

public struct BibleReference: Hashable, Comparable {
    public let version: Version
    public let reference: Verse.Reference

    public static func < (lhs: BibleReference, rhs: BibleReference) -> Bool {
        return lhs.version.abbr.compare(rhs.version.abbr) == .orderedAscending &&
            lhs.reference.book.id < rhs.reference.book.id
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
            \(version)_bible_index
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

    func search(_ string: String, offset: Int, count: Int) -> [Verse] {
        let string = string.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        let query =
        """
        SELECT
            book_id, verse, chapter, text
        FROM
            \(version)_bible_index
        WHERE
            text
        MATCH
            '\(string)'
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
            \(version)_bible
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
            \(version)_bible_books.id,
            \(version)_bible_books.idx,
            \(version)_bible_books.book AS title,
            \(version)_bible_books.alt,
            \(version)_bible_books.abbr,
            (SELECT
                COUNT(DISTINCT \(version)_bible.chapter)
            FROM \(version)_bible
            WHERE \(version)_bible.book_id = \(version)_bible_books.id) AS chapters
        FROM \(version)_bible_books;
        """

        return try storage.fetch(query).map(Book.init)
    }
}
