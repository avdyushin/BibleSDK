//
//  BibleSDK_iOS_Tests.swift
//  BibleSDK iOS Tests
//
//  Created by Grigory Avdyushin on 01/05/2019.
//

import XCTest
@testable import BibleSDK

class BibleSDK_iOS_Tests: XCTestCase {

    var bible: Bible!

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        bible = Bible()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        bible = nil
    }

    func testLoadNoThrow() {
        let path = Bundle(for: type(of: self)).path(forResource: "rst", ofType: "db")!
        XCTAssertNoThrow(try bible.load(path: path))
    }

    func testLoadThrow() {
        XCTAssertThrowsError(try bible.load(path: "no-data-base"))
    }
}
