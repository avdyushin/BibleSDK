//
//  Verse.swift
//  Woord
//
//  Created by Grigory Avdyushin on 16/02/2018.
//  Copyright © 2018 Grigory Avdyushin. All rights reserved.
//

import Foundation

/// Bible single verse object
///
/// Each Bible Verse is referenced by Chapter index and Number index
/// For example `John 3:16` has Chapter index `3` and Number index `16`
public struct Verse: Hashable, Equatable {

    public typealias ChapterIndex = Int
    public typealias VerseIndex = Int

    /// The identifier of the Book
    public let book: Book.BookId
    /// The Book name
    public let bookName: String?
    /// The Book abbreviation
    public let bookAlt: String?
    /// The Verse chapter index in the Book
    public let chapter: ChapterIndex
    /// The Verse number in the current Chapter
    public let number: VerseIndex
    /// The Text of the Verse
    public let text: String
}

extension Verse {
    init(row: Row) {
        self.init(
            book: row["book_id"]!,
            bookName: row["book_name"],
            bookAlt: row["book_alt"],
            chapter: row["chapter"]!,
            number: row["verse"]!,
            text: row["text"]!
        )
    }
}

public extension Verse {

    /// A Location of the Verses
    ///
    /// Reference to the Chapter(s) and Verse Number(s)
    ///
    /// If it's a set of multiple Chapters that means reference to all verses from the given Chapters
    struct Location: Hashable, Equatable, CustomStringConvertible {

        public let chapters: IndexSet
        public let verses: IndexSet

        public var description: String {
            let c = chapters.compactMap { "\($0)" }.joined(separator: ",")
            let v = verses.compactMap { "\($0)" }.joined(separator: ",")
            return "\(c):\(v)"
        }
    }

    /// A Raw Reference to the Verse inside Bible
    ///
    /// Contains string Book name as set of Locations
    struct RawReference: Hashable, Equatable {

        /// Raw Book name string (can be in any locale, or even wrong)
        public let bookName: String
        /// The Locations of Verses
        public let locations: Set<Location>
    }

    /// A Verses Reference
    ///
    /// Contains a link to the Book and set of Locations of Verses
    struct Reference: Hashable, Equatable, Comparable, CustomStringConvertible {

        /// A Book inside Bible
        public let book: Book
        /// A set of Locations
        public let locations: Set<Location>

        static public func <(lhs: Reference, rhs: Reference) -> Bool {
            return lhs.book.id < rhs.book.id
        }

        /// A Title of the Book
        public var title: String { return book.title }

        /// A first Chapter index
        public var firstChapter: Int {
            return locations.first?.chapters.first ?? 1
        }

        /// String representation of the Verse Reference
        ///
        /// For example: `Gen 1:1-10` or `2 Cor 1, 2`
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
