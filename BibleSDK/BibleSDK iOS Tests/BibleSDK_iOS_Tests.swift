//
//  BibleSDK_iOS_Tests.swift
//  BibleSDK iOS Tests
//
//  Created by Grigory Avdyushin on 01/05/2019.
//

import XCTest
@testable import BibleSDK

class BibleSDK_iOS_Tests: XCTestCase {

    func testDaily() {
        let b = BibleSDK()
        let refs = b.dailyContainer.dailyReferences(Date(timeIntervalSince1970: 123123123))
        XCTAssertEqual(refs.count, 14)
    }

    func testConversion() {
        let b = BibleSDK()
        let refs = b.dailyContainer.dailyReferences(Date(timeIntervalSince1970: 123123123))
        let conv = refs.compactMap { b.bibleContainer.references(raw: $0) }
        XCTAssertEqual(refs.count, conv.count)
    }

    func testKJVDailyReading() {
        let b = BibleSDK()
        let v = b.bibleContainer.availableVersions.first { $0.identifier == "kjv" }!
        let reading = b.dailyReading(Date(timeIntervalSince1970: 123123123), version: v)
        XCTAssertEqual(reading.keys.count, 14)
        dump(reading.keys)
        for (key, value) in reading {
            switch key.reference.title {
            case "2 Corinthians": XCTAssertEqual(value.count, 1)
            case "Psalms": XCTAssertEqual(value.count, 1)
            case "Jeremiah": XCTAssertEqual(value.count, 1)
            case "2 Samuel": XCTAssertEqual(value.count, 1)
            case "Matthew": XCTAssertEqual(value.count, 3)
            default:
                ()
            }
        }
    }

    func testRSTDailyReading() {
        let b = BibleSDK()
        let v = b.bibleContainer.availableVersions.first { $0.identifier == "rst" }!
        let reading = b.dailyReading(Date(timeIntervalSince1970: 123123123), version: v)
        XCTAssertEqual(reading.keys.count, 14)
    }

    func testFetchByRefs() {
        let b = BibleSDK()
        let verses = b.findByReference("Gen 1:1 Быт 1:1")
        XCTAssertEqual(verses.keys.count, 2)
        dump(verses)
    }

    func testConverter() {
        let b = BibleSDK()
        let v = b.findByReference("Gen 1:2-4")
        let c = VerseConverter<PlainTextVerseConverter>()
        let s = c.convert(verses: v.first!.value, styles: [.numbers(.verse)])
        XCTAssertEqual(s.string,
        """
        2 And the earth was without form, and void; and darkness was upon the face of the deep. And the Spirit of God moved upon the face of the waters.
        3 And God said, Let there be light: and there was light.
        4 And God saw the light, that it was good: and God divided the light from the darkness.
        """)
    }
}
