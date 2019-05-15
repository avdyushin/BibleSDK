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

    func testDailyReading() {
        let b = BibleSDK()
        let reading = b.dailyReading(Date(timeIntervalSince1970: 123123123))
        debugPrint(reading)
    }
}
