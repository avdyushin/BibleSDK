//
//  BibleContainer.swift
//  BibleSDK
//
//  Created by Grigory Avdyushin on 09/05/2019.
//

public class BibleContainer {

    private let bibles: [Version: BibleProtocol]

    public var availableVersions: [Version] {
        return bibles.keys.map { $0 }
    }

    public init() {
        let list = FileManager
            .default
            .enumerator(atPath: Bundle(for: type(of: self)).bundlePath)!
            .map { $0 as! String }
            .filter { $0.hasSuffix(".db") == true && $0 != "kjv_daily.db" }
            .map { try? Bible(name: $0) }
        self.bibles = Dictionary(uniqueKeysWithValues: list.map { ($0!.version, $0!) })
    }

    public func bible(abbr: String) -> BibleProtocol? {
        guard let version = availableVersions.first(where: { $0.identifier.lowercased() == abbr.lowercased() }) else {
            return nil
        }
        return bible(version: version)
    }

    public func bible(version: Version) -> BibleProtocol? {
        return bibles[version]
    }

    public func books(abbr: String) -> [Book] {
        guard let bible = bible(abbr: abbr) else {
            return []
        }
        return bible.books
    }

    public func books(version: Version) -> [Book] {
        guard let bible = bible(version: version) else {
            return []
        }
        return bible.books
    }

    public func verses(version: Version, bookId: Book.BookId, chapters: IndexSet = [], verses: IndexSet = []) -> [Verse] {
        guard let bible = bible(version: version) else {
            return []
        }
        return bible.verses(bookId: bookId, chapters: chapters, verses: verses)
    }

    public func verses(abbr: String, bookId: Book.BookId, chapters: IndexSet = [], verses: IndexSet = []) -> [Verse] {
        guard let bible = bible(abbr: abbr) else {
            return []
        }
        return bible.verses(bookId: bookId, chapters: chapters, verses: verses)
    }

    func verses(reference: Verse.Reference, version: Version) -> [Verse] {
        guard !reference.locations.isEmpty, let bible = bible(version: version) else {
            return []
        }

        return reference.locations.flatMap {
            bible.verses(bookId: reference.book.id, chapters: $0.chapters, verses: $0.verses)
        }
    }

    func references(raw: Verse.RawReference) -> BibleReference? {
        return bibles.values.compactMap {
            if let book = $0.book(by: raw.bookName) {
                return BibleReference(
                    version: $0.version,
                    reference: Verse.Reference(book: book, locations: raw.locations)
                )
            }
            return nil
        }.first
    }
}
