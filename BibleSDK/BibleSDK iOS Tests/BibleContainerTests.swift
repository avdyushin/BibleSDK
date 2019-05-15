//
//  BibleContainerTests.swift
//  BibleSDK iOS Tests
//
//  Created by Grigory Avdyushin on 09/05/2019.
//

import XCTest
@testable import BibleSDK

class BibleContainerTests: XCTestCase {

    func testBuildinVersionsCount() {
        XCTAssertEqual(BibleContainer().availableVersions.count, 2)
    }

    func testBooksByName() {
        let container = BibleContainer()
        let bible = container.bible(abbr: "kjv")
        let gen = bible?.book(by: "ge")
        XCTAssertEqual(gen?.title, "Genesis")
        XCTAssertEqual(gen?.id, 1)

        let ze = bible?.book(by: "ze")
        XCTAssertEqual(ze?.title, "Zephaniah")
    }
    
    func testVersesByBookId() {
        let container = BibleContainer()
        let bible = container.bible(abbr: "kjv")!
        XCTAssertEqual(bible.books.last?.chaptersCount, 22)
        let verses = bible.verses(bookId: 66)
        XCTAssertEqual(verses.count, 404)
    }

    func testVersesByBookAndChapter() {
        let container = BibleContainer()
        let bible = container.bible(abbr: "kjv")!
        let verses = bible.verses(bookId: 66, chapters: [1])
        XCTAssertEqual(verses.count, 20)
    }

    func testVersesByBookAndChapterAndVerses() {
        let container = BibleContainer()
        let bible = container.bible(abbr: "kjv")!
        let verses = bible.verses(bookId: 66, chapters: [1], verses: [1, 2])
        XCTAssertEqual(verses.count, 2)
    }
}
