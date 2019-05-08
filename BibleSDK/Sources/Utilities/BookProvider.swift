//
//  BookProvider.swift
//  Woord
//
//  Created by Grigory Avdyushin on 16/02/2018.
//  Copyright © 2018 Grigory Avdyushin. All rights reserved.
//

import Foundation

struct BookProvider {

    let storage: Storage

    func findBook(byId id: Int) -> Book? {
        let query =
        """
        SELECT
            id, book as title, alt, abbr
        FROM
            rst_bible_books
        WHERE
            id = '\(id)'
        LIMIT
            1;
        """

        guard let rows = try? storage.fetch(query) else {
            assertionFailure("All books should be reachable")
            return nil
        }

        return rows.map { data in
            Book(id: data["id"]!, title: data["title"]!, alt: data["alt"]!, abbr: data["abbr"]!, chaptersCount: 0)
        }.first
    }

    func findBook(byName name: String) -> Book? {
        return findBooks(by: name).first
    }

    func findBooks(by name: String) -> [Book] {

        let name = name.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        guard name.isEmpty == false else {
            return []
        }

        let query =
        """
        SELECT
            id, book as title, alt, abbr
        FROM
            rst_bible_books
        WHERE
            (UTF8_UPPER(book) LIKE '\(name)%') OR
            (UTF8_UPPER(abbr) LIKE '\(name)%') OR
            (UTF8_UPPER(alt) LIKE '\(name)%');
        """

        guard let rows = try? storage.fetch(query) else {
            return []
        }

        return rows.map { data in
            Book(id: data["id"]!, title: data["title"]!, alt: data["alt"]!, abbr: data["abbr"]!, chaptersCount: 0)
        }
    }

    var allBooks: [Book] {
        let query =
        """
        SELECT
            rst_bible_books.id, rst_bible_books.book as title, rst_bible_books.alt, rst_bible_books.abbr,
            (SELECT COUNT(DISTINCT rst_bible.chapter) FROM rst_bible WHERE rst_bible.book_id = rst_bible_books.id) AS chapters
        FROM rst_bible_books;
        """

        guard let rows = try? storage.fetch(query) else {
            return []
        }

        return rows.compactMap { data in
            Book(id: data["id"]!, title: data["title"]!, alt: data["alt"]!, abbr: data["abbr"]!, chaptersCount: data["chapters"]!)
        }
    }

    func allVerses(book: Book) -> [Verse] {
        let query =
        """
        SELECT
            verse, chapter, text
        FROM
            rst_bible
        WHERE
            book_id = \(book.id);
        """

        guard let rows = try? storage.fetch(query) else {
            assert(false, "No verses for given book: \(book)")
            return []
        }
        return rows.compactMap { data in
            Verse(book: book, chapter: data["chapter"]!, number: data["verse"]!, text: data["text"]!)
        }
    }

    func findVersesIterator(search text: String, step: Int = 10) -> (Int, AnyIterator<[Verse]>) {
        precondition(step > 0)
        let total = findVersesTextChunksCount(search: text)
        var current = 0
        return (total, AnyIterator {
            guard total > 0 else {
                return nil
            }
            guard current < total else {
                return nil
            }

            let next = self.findVersesTextChunks(search: text, start: current, count: step)
            current += next.count
            return next
        })
    }

    func findVersesTextChunksCount(search text: String) -> Int {
        let text = text.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        let query =
        """
        SELECT
            COUNT(*)
        FROM
            rst_bible
        WHERE
            UTF8_UPPER(text)
        LIKE
            '%\(text)%';
        """

        guard let row = try? storage.fetch(query).first else {
            debugPrint("No rows for \(query) returned!")
            return 0
        }
        let count: Int = row["COUNT(*)"] ?? 0
        return count
    }

    func findVersesTextChunks(search text: String, start: Int, count: Int) -> [Verse] {
        let text = text.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        let query =
        """
        SELECT
            book_id, verse, chapter, text
        FROM
            rst_bible
        WHERE
            UTF8_UPPER(text)
        LIKE
            '%\(text)%'
        LIMIT
            \(start), \(count);
        """

        guard let rows = try? storage.fetch(query) else {
            debugPrint("No rows for \(query) returned!")
            return []
        }

        return rows.compactMap { data in
            guard let book = findBook(byId: data["book_id"]!) else {
                debugPrint("No book was found for: \(data)")
                return nil
            }
            return Verse(book: book, chapter: data["chapter"]!, number: data["verse"]!, text: data["text"]!)
        }
    }

    func findVerses(book: Book, chapter: Int, verses: IndexSet = []) -> [Verse] {
        precondition(chapter >= 0)

        let query: String

        if verses.isEmpty {
            query =
            """
            SELECT verse, text
            FROM rst_bible
            WHERE (book_id = \(book.id)) AND
            (chapter = \(chapter));
            """
        } else {
            let set = verses.map { "\($0)" } .joined(separator: ",")

            query =
            """
            SELECT verse, text
            FROM rst_bible
            WHERE (book_id = \(book.id)) AND
            (chapter = \(chapter)) AND
            (verse IN (\(set)));
            """
        }

        guard let rows = try? storage.fetch(query) else {
            return []
        }
        return rows.compactMap { data in
            Verse(book: book, chapter: chapter, number: data["verse"]!, text: data["text"]!)
        }
    }

    func findVerses(book: Book, chapters: IndexSet) -> [Verse] {
        precondition(chapters.isEmpty == false)

        let set = chapters.compactMap { "\($0)" }.joined(separator: ",")
        let query =
        """
        SELECT chapter, verse, text
        FROM rst_bible
        WHERE (book_id = \(book.id)) AND
        (chapter IN (\(set)));
        """
        guard let rows = try? storage.fetch(query) else {
            return []
        }
        return rows.compactMap { data in
            Verse(book: book, chapter: data["chapter"]!, number: data["verse"]!, text: data["text"]!)
        }
    }

    func findBookReference(by reference: Verse.RawReference) -> Verse.Reference? {
        guard let book = findBook(byName: reference.bookName) else {
            return nil
        }
        return Verse.Reference(book: book, locations: reference.locations)
    }

    func findVerses(by reference: Verse.Reference) -> [Verse] {
        precondition(reference.locations.isEmpty == false)

        var result = [[Verse]]()
        reference.locations.forEach {
            if $0.chapters.count == 1 {
                guard let chapter = $0.chapters.first else {
                    return
                }
                result.append(findVerses(book: reference.book, chapter: chapter, verses: $0.verses))
            } else {
                result.append(findVerses(book: reference.book, chapters: $0.chapters))
            }
        }
        return result.flatMap { $0 }
    }
}
