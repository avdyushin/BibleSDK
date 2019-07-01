//
//  Bible.swift
//  BibleSDK
//
//  Created by Grigory Avdyushin on 09/05/2019.
//

// A Bible Protocol
public protocol BibleProtocol {
    /// A Version (Translation) of the Bible
    var version: Version { get }
    /// A list of Books
    var books: [Book] { get }
    /// Returns Book by given `name` if exists
    /// - Parameter name: The name of the book
    func book(name: String) -> Book?
    /// Returns Book by given `id` if exists
    /// - Parameter id: The id of the book
    func book(id: Book.BookId) -> Book?
    /// Returns Verses list by given Book identifier, Chapters set and Verses set
    /// - Parameters:
    ///     - bookId: The identifier of the book
    ///     - chapters: The set of chapters indexes
    ///     - verses: The set of verses indexes
    func verses(bookId: Book.BookId, chapters: IndexSet, verses: IndexSet) -> [Verse]
    /// Returns count of search results for given search string
    func searchCount(_ string: String) -> Int
    /// Returns search results for given string with offset and count
    /// - Parameters:
    ///     - string: The string pattern to search
    ///     - offset: The offset of all search results
    ///     - count: The count of search results to return
    ///     - surround: The prefix and suffix string to surround search string in results
    func search(_ string: String, offset: Int, count: Int, surround: (String, String)?) -> [Verse]
    /// Returns Book by given `id`
    subscript(id: Book.BookId) -> Book? { get }
    /// Returns Book by given `name`
    subscript(name: String) -> Book? { get }
}

/// A Bible Reference
/// Each Bible is referenced by Version and Verse Reference
public struct BibleReference: Hashable, Comparable {
    public let version: Version
    public let reference: Verse.Reference

    public static func < (lhs: BibleReference, rhs: BibleReference) -> Bool {
        return lhs.reference < rhs.reference
    }
}

extension BibleProtocol {
    func verses(bookId: Book.BookId, chapters: IndexSet = [], verses: IndexSet = []) -> [Verse] {
        return self.verses(bookId: bookId, chapters: chapters, verses: verses)
    }
}

/// Internal implementaion of the BibleProtocol
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
