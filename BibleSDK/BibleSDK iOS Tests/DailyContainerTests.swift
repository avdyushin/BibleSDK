//
//  DailyContainerTests.swift
//  BibleSDK iOS Tests
//
//  Created by Grigory Avdyushin on 30/05/2019.
//

import XCTest
@testable import BibleSDK

class DailyContainerTests: XCTestCase {

    var sdk: BibleSDK!

    override func setUp() {
        super.setUp()
        sdk = BibleSDK()
    }

    override func tearDown() {
        sdk = nil
        super.tearDown()
    }

    func testSpecificDailyReferenceCount() {
        let refs = sdk.dailyContainer.dailyReferences(Date(timeIntervalSince1970: 123123123))
        XCTAssertEqual(refs.count, 14)
    }

    func testSpecificDailyReferenceConvertion() {
        let refs = sdk.dailyContainer.dailyReferences(Date(timeIntervalSince1970: 123123123))
        let conv = refs.map { sdk.bibleContainer.references(raw: $0) }
        XCTAssertEqual(refs.count, conv.count)
    }

    func testMapRefsToVerses() {
        let c = DateComponents(calendar: Calendar.current, year: 2019, month: 9, day: 19)
        let date = Calendar.current.date(from: c)!
        let dict = sdk.dailyReading(date, version: "kjv")
        for (key, value) in dict {
            XCTAssertEqual(key.reference.book.id, value.first!.book)
        }
    }
}
