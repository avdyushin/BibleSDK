//
//  Abbreviation.swift
//  Woord
//
//  Created by Grigory Avdyushin on 16/02/2018.
//  Copyright © 2018 Grigory Avdyushin. All rights reserved.
//

import Foundation

protocol Abbreviation {
    func matches(_ string: String) -> [Verse.RawReference]
}

struct BibleAbbreviation: Abbreviation {

    static let LocationPattern =
        "(?<Chapter>1?[0-9]?[0-9])" +
        "(-(?<ChapterEnd>\\d+)|,\\s*(?<ChapterNext>\\d+))*" +
        "(:\\s*(?<Verse>\\d+))?" +
        "(-(?<VerseEnd>\\d+)|,\\s*(?<VerseNext>\\d+))*"

    static let AbbreviationPattern =
        "(?<Book>(([1234]|I{1,4})[\\t\\f\\p{Z}]*)?\\p{Word}+\\.?)[\\t\\f\\p{Z}]+" +
        "(?<Locations>(\(BibleAbbreviation.LocationPattern)\\s?)+)"

    private let abbreviationsRegex: Regex
    private let locationsRegex: Regex

    init() throws {
        abbreviationsRegex = try Regex(pattern: BibleAbbreviation.AbbreviationPattern, options: [.caseInsensitive])
        locationsRegex = try Regex(pattern: BibleAbbreviation.LocationPattern)
    }

    func matches(_ string: String) -> [Verse.RawReference] {
        return abbreviationsRegex.matches(string).compactMap {

            guard let bookValue: String = $0.resultValue(string, withName: "Book") else {
                return nil
            }

            guard let locationsValue: String = $0.resultValue(string, withName: "Locations") else {
                return nil
            }

            let locations = extractLocations(locationsValue)
            return Verse.RawReference(bookName: bookValue, locations: Set(locations))
        }
    }

    fileprivate func extractLocations(_ string: String) -> [Verse.Location] {

        return locationsRegex.matches(string).compactMap {

            guard let chapterValue: Int = $0.resultValue(string, withName: "Chapter") else {
                return nil
            }

            let chapterEndValue: Int? = $0.resultValue(string, withName: "ChapterEnd")
            let chapterNextValue: Int? = $0.resultValue(string, withName: "ChapterNext")

            var chapters: IndexSet = [chapterValue]
            if let chapterEndValue = chapterEndValue {
                chapters.insert(integersIn: chapterValue...chapterEndValue)
            }
            if let chapterNextValue = chapterNextValue {
                chapters.insert(chapterNextValue)
            }

            let verseValue: Int? = $0.resultValue(string, withName: "Verse")
            let verseEndValue: Int? = $0.resultValue(string, withName: "VerseEnd")
            let verseNextValue: Int? = $0.resultValue(string, withName: "VerseNext")

            var verses: IndexSet = []
            if let verseValue = verseValue {
                verses = [verseValue]
                if let verseEndValue = verseEndValue {
                    verses.insert(integersIn: verseValue...verseEndValue)
                }
                if let verseNextValue = verseNextValue {
                    verses.insert(verseNextValue)
                }
            }

            return Verse.Location(chapters: chapters, verses: verses)
        }
    }
}
