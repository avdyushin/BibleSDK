//
//  Main.swift
//  BibleSDK
//
//  Created by Grigory Avdyushin on 30/04/2019.
//

public class BibleSDK {

    public typealias VerseByReference = [BibleReference: [Verse]]

    let abbreviation = try! BibleAbbreviation()
    let bibleContainer = BibleContainer()
    let dailyContainer: DailyContainer

    public init() {
        let path = Bundle(for: type(of: self)).path(forResource: "kjv_daily", ofType: "db")!
        let storage = try! SqliteStorage(filename: path)
        self.dailyContainer = DailyContainer(storage: storage, abbreviation: abbreviation)
    }

    public func dailyReading(_ date: Date = Date(), version: Version) -> VerseByReference  {
        let references = dailyContainer
            .dailyReferences(date)
            .compactMap { bibleContainer.references(raw: $0) }

        guard !references.isEmpty else {
            return [:]
        }

        let verses = references.map {
            bibleContainer.verses(reference: $0.reference, version: version)
        }
        return Dictionary(uniqueKeysWithValues: zip(references, verses))
    }

    public func findByReference(_ string: String) -> VerseByReference {
        let references = abbreviation
            .matches(string)
            .compactMap { bibleContainer.references(raw: $0) }

        guard !references.isEmpty else {
            return [:]
        }

        let verses = references.map {
            bibleContainer.verses(reference: $0.reference, version: $0.version)
        }
        return Dictionary(uniqueKeysWithValues: zip(references, verses))
    }
}
