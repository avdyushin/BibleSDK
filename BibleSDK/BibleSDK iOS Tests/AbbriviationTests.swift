//
//  AbbriviationTests.swift
//  BibleSDK iOS Tests
//
//  Created by Grigory Avdyushin on 01/05/2019.
//

import XCTest
@testable import BibleSDK

class AbbriviationTests: XCTestCase {

    var abbreviation: Abbreviation!

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        abbreviation = try! BibleAbbreviation()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        abbreviation = nil
        super.tearDown()
    }


    func testInit() {
        XCTAssertNoThrow(try BibleAbbreviation())
    }

    func testMatchBook() {
        let results = abbreviation.matches("Gen 1")
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.bookName, "Gen")
    }

    func testMatchBookWithPrefix() {
        let results = abbreviation.matches("1Cor 1")
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.bookName, "1Cor")
    }

    func testMatchBookWithPrefixAndSpace() {
        let results = abbreviation.matches("3 King 1")
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.bookName, "3 King")
    }

    func testMatchBook1Chapter() {
        let results = abbreviation.matches("Gen 1")
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.bookName, "Gen")
        XCTAssertEqual(results.first?.locations.first?.chapters, [1])
    }

    func testMatchBook1Chapter1Verse() {
        let results = abbreviation.matches("Gen 1:1")
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.bookName, "Gen")
        XCTAssertEqual(results.first?.locations.first?.chapters, [1])
        XCTAssertEqual(results.first?.locations.first?.verses, [1])
    }

    func testMatchBook1ChapterVerseSequence() {
        let results = abbreviation.matches("Gen 1:1,2")
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.bookName, "Gen")
        XCTAssertEqual(results.first?.locations.first?.chapters, [1])
        XCTAssertEqual(results.first?.locations.first?.verses, [1,2])
    }

    func testMatchBook1ChapterVerseRange() {
        let results = abbreviation.matches("Gen 1:3-6")
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.bookName, "Gen")
        XCTAssertEqual(results.first?.locations.first?.chapters, [1])
        XCTAssertEqual(results.first?.locations.first?.verses, [3, 4, 5, 6])
    }

    func testMatchBook1ChapterInvalidVerseRange() {
        let results = abbreviation.matches("Gen 1:6-3")
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.bookName, "Gen")
        XCTAssertEqual(results.first?.locations.first?.chapters, [1])
        XCTAssertEqual(results.first?.locations.first?.verses, [6])
    }

    func testMatchBookWithPrefixAndSpaceVerseRange() {
        let results = abbreviation.matches("3 King 1:3-4")
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.bookName, "3 King")
        XCTAssertEqual(results.first?.locations.first?.chapters, [1])
        XCTAssertEqual(results.first?.locations.first?.verses, [3, 4])
    }

    func testMatchBookWithPrefixAndSpaceVerseRangeAndSequence() {
        let results = abbreviation.matches("3 King 1:2-4, 6")
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.bookName, "3 King")
        XCTAssertEqual(results.first?.locations.first?.chapters, [1])
        XCTAssertEqual(results.first?.locations.first?.verses, [2, 3, 4, 6])
    }

    func testMatchBookChaptersRange() {
        let results = abbreviation.matches("Gen 1-3")
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.bookName, "Gen")
        XCTAssertEqual(results.first?.locations.first?.chapters, [1, 2, 3])
    }

    func testMatchBookChaptersInvalidRange() {
        let results = abbreviation.matches("Gen 3-1")
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.bookName, "Gen")
        XCTAssertEqual(results.first?.locations.first?.chapters, [3])
    }

    func testMatchBookChaptersSequence() {
        let results = abbreviation.matches("Gen 4, 5")
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.bookName, "Gen")
        XCTAssertEqual(results.first?.locations.first?.chapters, [4, 5])
    }

    func testMatchBookChaptersRangeAndSequence() {
        let results = abbreviation.matches("Gen 1-3,5")
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.bookName, "Gen")
        XCTAssertEqual(results.first?.locations.first?.chapters, [1, 2, 3, 5])
    }

    func testMatchBookChaptersComplex() {
        let results = abbreviation.matches("II Ki. 3:12-14, 25")
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.bookName, "II Ki.")
        XCTAssertEqual(results.first?.locations.first?.chapters, [3])
        XCTAssertEqual(results.first?.locations.first?.verses, [12, 13, 14, 25])
    }

    func testMatchBookProverbs() {
        let results = abbreviation.matches("Притч 28:27,28")
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.bookName, "Притч")
        XCTAssertEqual(results.first?.locations.first?.chapters, [28])
        XCTAssertEqual(results.first?.locations.first?.verses, [27, 28])
    }

    func testMatchTwoReferences() {
        let results = abbreviation.matches("Hi here is Gen 1:1-2 and more: II Ki. 3:12-14, 25. Cool!")
        XCTAssertEqual(results.count, 2)
        XCTAssertEqual(results.first?.bookName, "Gen")
        XCTAssertEqual(results.first?.locations.first?.chapters, [1])
        XCTAssertEqual(results.first?.locations.first?.verses, [1, 2])
        XCTAssertEqual(results.last?.bookName, "II Ki.")
        XCTAssertEqual(results.last?.locations.first?.chapters, [3])
        XCTAssertEqual(results.last?.locations.first?.verses, [12, 13, 14, 25])
    }

    func testMultiline() {
        let results = abbreviation.matches(
            """
            10:22 Here is my notes
            1:2 this is one
            2:3 this is two
            """
        )
        XCTAssertTrue(results.isEmpty)
    }

    func testMultilineWithNumericBookPrefix() {
        let results = abbreviation.matches(
            """
            Some notes header goes here

            1 Cor 1:1
            2 Cor 1:1

            The rest of notes
            """
        )
        XCTAssertEqual(2, results.count)
        XCTAssertEqual(results.first?.bookName, "1 Cor")
        XCTAssertEqual(results.first?.locations.first?.chapters, [1])
        XCTAssertEqual(results.first?.locations.first?.verses, [1])
        XCTAssertEqual(results.last?.bookName, "2 Cor")
        XCTAssertEqual(results.last?.locations.first?.chapters, [1])
        XCTAssertEqual(results.last?.locations.first?.verses, [1])
    }
}
