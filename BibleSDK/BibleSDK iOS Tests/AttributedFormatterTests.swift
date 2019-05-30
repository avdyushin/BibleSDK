//
//  AttributedFormatterTests.swift
//  BibleSDK iOS Tests
//
//  Created by Grigory Avdyushin on 29/05/2019.
//

import XCTest
@testable import BibleSDK

class AttributedFormatterTests: XCTestCase {

    var verses: [Verse]!
    var converter: VerseFormatter<AttributedStringVerseFormatter>!

    override func setUp() {
        super.setUp()

        verses = BibleSDK().findByReference("Gen 1:2-4").first!.value
        converter = VerseFormatter<AttributedStringVerseFormatter>()
    }

    override func tearDown() {
        converter = nil
        verses.removeAll()

        super.tearDown()
    }

    func testPlainTextNoReference() {
        let string = converter.convert(verses: verses, style: .none)
        XCTAssertEqual(
            string.string,
            """
            And the earth was without form, and void; and darkness was upon the face of the deep. And the Spirit of God moved upon the face of the waters.
            And God said, Let there be light: and there was light.
            And God saw the light, that it was good: and God divided the light from the darkness.
            """
        )
    }

    func testPlainTextVerseNumber() {
        let string = converter.convert(verses: verses, style: .verseNumber)
        XCTAssertEqual(
            string.string,
            """
            2 And the earth was without form, and void; and darkness was upon the face of the deep. And the Spirit of God moved upon the face of the waters.
            3 And God said, Let there be light: and there was light.
            4 And God saw the light, that it was good: and God divided the light from the darkness.
            """
        )
    }

    func testPlainTextChapterAndVerse() {
        let string = converter.convert(verses: verses, style: .chapterAndVerse)
        XCTAssertEqual(
            string.string,
            """
            1:2 And the earth was without form, and void; and darkness was upon the face of the deep. And the Spirit of God moved upon the face of the waters.
            1:3 And God said, Let there be light: and there was light.
            1:4 And God saw the light, that it was good: and God divided the light from the darkness.
            """
        )
    }
}
