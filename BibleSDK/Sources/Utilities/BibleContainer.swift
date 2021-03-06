//
//  BibleContainer.swift
//  BibleSDK
//
//  Created by Grigory Avdyushin on 09/05/2019.
//

public class BibleContainer {

    private var bibles: [Version: BibleProtocol]

    public var availableVersions: [Version] {
        return bibles.keys.map { $0 }
    }

    public init() {
        let path = Bundle(for: type(of: self)).path(forResource: "kjv", ofType: "db")!
        let kjv = try! Bible(version: Version("kjv"), path: path)
        self.bibles = [kjv.version: kjv]
    }

    public func load(version: Version, path: String) throws {
        guard !bibles.keys.contains(version) else {
            return
        }
        bibles[version] = try Bible(version: version, path: path)
    }

    public func bible(abbr: String) -> BibleProtocol? {
        guard let version = availableVersions.first(where: { $0.identifier.lowercased() == abbr.lowercased() }) else {
            return nil
        }
        return self[version]
    }

    subscript(version: Version) -> BibleProtocol? {
        return bibles[version]
    }

    public func books(abbr: String) -> [Book] {
        guard let bible = bible(abbr: abbr) else {
            return []
        }
        return bible.books
    }

    public func books(version: Version) -> [Book] {
        guard let bible = self[version] else {
            return []
        }
        return bible.books
    }

    public func verses(version: Version, bookId: Book.BookId, chapters: IndexSet = [], verses: IndexSet = []) -> [Verse] {
        guard let bible = self[version] else {
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

    func searchCount(_ string: String) -> [Version: Int] {
        let counts = bibles.map { $1.searchCount(string) }
        return Dictionary(uniqueKeysWithValues: zip(availableVersions, counts))
    }

    func searchIterator(_ string: String, version: Version, chunks: Int = 10, surround: (String, String)? = nil) -> AnyIterator<[Verse]> {
        guard
            let bible = self[version],
            let total = searchCount(string)[version], total > 0 else {
                return AnyIterator { nil }
        }

        var current = 0
        return AnyIterator {
            guard total > 0 else {
                return nil
            }
            guard current < total else {
                return nil
            }

            let next = bible.search(string, offset: current, count: chunks, surround: surround)
            current += next.count
            return next
        }
    }
    
    func verses(reference: Verse.Reference, version: Version) -> [Verse] {
        guard !reference.locations.isEmpty, let bible = self[version] else {
            return []
        }

        return reference.locations.flatMap {
            bible.verses(bookId: reference.book.id, chapters: $0.chapters, verses: $0.verses)
        }
    }

    func references(raw: Verse.RawReference, version: Version? = nil) -> BibleReference? {
        return bibles.values.compactMap {
            if let book = $0.book(name: raw.bookName) {
                if let version = version, let bible = self[version], let bookInVersion = bible.book(id: book.id) {
                    return BibleReference(
                        version: version,
                        reference: Verse.Reference(book: bookInVersion, locations: raw.locations)
                    )
                } else {
                    return BibleReference(
                        version: $0.version,
                        reference: Verse.Reference(book: book, locations: raw.locations)
                    )
                }
            }
            return nil
        }.first
    }
}
