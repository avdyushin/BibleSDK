//
//  Bible.swift
//  BibleSDK
//
//  Created by Grigory Avdyushin on 09/05/2019.
//

public protocol BibleProtocol {
    var version: Version { get }
    var books: [Book] { get }
    func book(by name: String) -> Book?
    func verses(bookId: Book.BookId, chapters: IndexSet, verses: IndexSet) -> [Verse]
}

extension BibleProtocol {
    func verses(bookId: Book.BookId, chapters: IndexSet = [], verses: IndexSet = []) -> [Verse] {
        return self.verses(bookId: bookId, chapters: chapters, verses: verses)
    }
}

class Bible: BibleProtocol {

    struct Reference: Hashable {
        static func == (lhs: Bible.Reference, rhs: Bible.Reference) -> Bool {
            return lhs.bible.version == rhs.bible.version &&
                   lhs.verseReference == rhs.verseReference
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(bible.version)
            hasher.combine(verseReference)
        }

        let bible: BibleProtocol
        let verseReference: Verse.Reference
    }

    let version: Version
    let storage: Storage
    lazy var books = try! fetchAllBooks()

    init(name: String) throws {
        self.version = Version(name: name)
        let path = Bundle(for: type(of: self)).path(forResource: name, ofType: nil)!
        self.storage = try BaseSqliteStorage(filename: path)
    }

    func book(by name: String) -> Book? {
        return books.first {
            $0.title.lowercased().hasPrefix(name.lowercased()) ||
            $0.alt.lowercased().hasPrefix(name.lowercased()) ||
            $0.abbr.lowercased().hasPrefix(name.lowercased())
        }
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
            //debugPrint(query)
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
