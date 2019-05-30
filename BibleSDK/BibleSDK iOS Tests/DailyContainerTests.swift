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
}
