//
//  Verse.swift
//  Woord
//
//  Created by Grigory Avdyushin on 16/02/2018.
//  Copyright © 2018 Grigory Avdyushin. All rights reserved.
//

import Foundation

public struct Verse: Hashable, Equatable {

    public typealias BookId = Int
    public typealias ChapterIndex = Int
    public typealias VerseIndex = Int

    public let book: Book
    public let chapter: ChapterIndex
    public let number: VerseIndex
    public let text: String

    init(book: Book, chapter: ChapterIndex, number: VerseIndex, text: String) {
        self.book = book
        self.chapter = chapter
        self.number = number
        self.text = text
    }
}

public extension Verse {

    struct Location: Hashable, Equatable, CustomDebugStringConvertible {

        public let chapters: IndexSet
        public let verses: IndexSet

        public var debugDescription: String {
            let c = chapters.compactMap { "\($0)" }.joined(separator: ",")
            let v = verses.compactMap { "\($0)" }.joined(separator: ",")
            return "\(c):\(v)"
        }
    }

    struct RawReference: Hashable, Equatable {

        public let bookName: String
        public let locations: Set<Location>
    }

    struct Reference: Hashable, Equatable, Comparable, CustomStringConvertible {

        let book: Book
        let locations: Set<Location>

        static public func <(lhs: Reference, rhs: Reference) -> Bool {
            return lhs.book.id < rhs.book.id
        }

        public var title: String { return book.title }

        public var firstChapter: Int {
            return locations.first?.chapters.first ?? 1
        }

        public var description: String {

            var locationStrings = [String]()

            locations.forEach {
                let chapters = $0.chapters
                let verses = $0.verses

                let chaptersString: String
                if chapters.count > 2, let first = chapters.first, let last = chapters.last {
                    chaptersString = "\(first)-\(last)"
                } else if chapters.count == 2, let first = chapters.first, let last = chapters.last  {
                    chaptersString = "\(first), \(last)"
                } else if let chapter = chapters.first {
                    chaptersString = "\(chapter)"
                } else {
                    chaptersString = "" // Should be never called
                }

                let versesString: String
                if verses.count > 2, let first = verses.first, let last = verses.last {
                    versesString = ":\(first)-\(last)"
                } else if verses.count == 2, let first = verses.first, let last = verses.last {
                    versesString = ":\(first), \(last)"
                } else if verses.count == 1, let verse = verses.first {
                    versesString = ":\(verse)"
                } else {
                    versesString = "" // Only chapter was provided (no exact verse(s))
                }

                locationStrings.append("\(chaptersString)\(versesString)")
            }

            let locationsString = locationStrings.joined(separator: ", ")

            return "\(book.title) \(locationsString)"
        }
    }
}
