//
//  Main.swift
//  BibleSDK
//
//  Created by Grigory Avdyushin on 30/04/2019.
//

public typealias VerseByReference = [BibleReference: [Verse]]

public class BibleSDK {

    let abbreviation = try! BibleAbbreviation()
    let bibleContainer = BibleContainer()
    let dailyContainer: DailyContainer

    public var availableVersions: [Version] {
        return bibleContainer.availableVersions
    }

    public subscript(version: Version) -> BibleProtocol? {
        return bibleContainer[version]
    }

    public subscript(abbr: String) -> BibleProtocol? {
        return self[Version(abbr)]
    }

    public init() {
        let path = Bundle(for: type(of: self)).path(forResource: "kjv_daily", ofType: "db")!
        let storage = try! BaseSqliteStorage(filename: path)
        self.dailyContainer = DailyContainer(storage: storage, abbreviation: abbreviation)
    }

    /// Loads Bible database
    /// - Parameters:
    ///     - version: Bible Version (Translation)
    ///     - filename: Path to SQLite Database file
    ///
    /// - Throws: An error if file not found
    public func load(version: Version, filename: String) throws {
        try bibleContainer.load(version: version, path: filename)
    }

    /// Returns Daily Reading Verses for given date and version
    /// - Parameters:
    ///     - data: The date to return daily reading
    ///     - version: The Bible Version to fetch daily reading from
    public func dailyReading(_ date: Date = Date(), version: Version) -> VerseByReference  {
        let references = dailyContainer
            .dailyReferences(date)
            .reduce([], { $0.contains($1) ? $0 : $0 + [$1] })
            .compactMap { bibleContainer.references(raw: $0, version: version) }

        guard !references.isEmpty else {
            assertionFailure()
            return [:]
        }

        let verses = references
            .map { bibleContainer.verses(reference: $0.reference, version: version) }
            .filter { !$0.isEmpty }

        return Dictionary(uniqueKeysWithValues: zip(references, verses))
    }

    /// Returns Verses by given Bible string reference
    /// - Parameter string: A Bible string reference like `Gen 1:1-2`
    public func findByReference(_ string: String) -> VerseByReference {
        let references = abbreviation
            .matches(string)
            .reduce([], { $0.contains($1) ? $0 : $0 + [$1] })
            .compactMap { bibleContainer.references(raw: $0) }

        guard !references.isEmpty else {
            return [:]
        }

        let verses = references
            .map { bibleContainer.verses(reference: $0.reference, version: $0.version) }
            .filter { !$0.isEmpty }

        return Dictionary(uniqueKeysWithValues: zip(references, verses))
    }

    /// Returns Verses by given book, chapter(s) and verses numbers
    /// - Parameters:
    ///     - book: A Book to fetch Verses from
    ///     - chapters: A Chapters index(es)
    ///     - verses: A Verses index(es)
    ///     - version: A Bible Version
    public func versesByBook(_ book: Book, chapters: IndexSet = [], verses: IndexSet = [], version: Version) -> VerseByReference {
        let bookReference = BibleReference(
            version: version,
            reference: Verse.Reference(
                book: book,
                locations: [Verse.Location(chapters: chapters, verses: verses)]
            )
        )
        let verses = bibleContainer.verses(version: version, bookId: book.id, chapters: chapters, verses: verses)
        return [bookReference: verses]
    }

    /// Returns search results count
    /// - Parameter string: A search string
    ///
    /// - Returns: A Dictionary with Version as a Key and count as a Value
    public func searchCount(_ string: String) -> [Version: Int] {
        return bibleContainer.searchCount(string)
    }

    /// Returns search iterator for given string
    /// - Parameters:
    ///     - string: A search string
    ///     - version: A Bible Version
    ///     - chunks: A number of batch items to fetch in one call
    ///     - surround: A prefix and suffix to surrdoun search string in results
    /// - Returns: An iterator of list of Verses
    public func searchIterator(_ string: String, version: Version, chunks: Int = 10, surround: (String, String)? = nil) -> AnyIterator<[Verse]> {
        return bibleContainer.searchIterator(string, version: version, chunks: chunks, surround: surround)
    }
}
