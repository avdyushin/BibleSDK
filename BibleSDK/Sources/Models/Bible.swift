//
//  Bible.swift
//  BibleSDK
//
//  Created by Grigory Avdyushin on 09/05/2019.
//

class Bible {

    let version: String
    let storage: Storage
    lazy var books = try! fetchAllBooks()

    init(version: String) throws {
        let path = Bundle(for: type(of: self)).path(forResource: version, ofType: nil)!
        self.version = ((version as NSString).lastPathComponent as NSString).deletingPathExtension
        self.storage = try BaseSqliteStorage(filename: path)
    }

    func verses(bookId: Book.BookId, chapters: IndexSet = [], verses: IndexSet = []) -> [Verse] {
        let query =
        """
        SELECT
            book_id, verse, chapter, text
        FROM
            \(version)_bible
        WHERE
            book_id = \(bookId);
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
