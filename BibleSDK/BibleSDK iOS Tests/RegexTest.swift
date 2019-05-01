//
//  RegexTest.swift
//  WoordTests
//
//  Created by Grigory Avdyushin on 16/02/2018.
//  Copyright © 2018 Grigory Avdyushin. All rights reserved.
//

import XCTest
@testable import BibleSDK

class RegexTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testNoThrow() {
        XCTAssertNoThrow(try Regex(pattern: "(\\d+)"))
    }

    func testThrow() {
        XCTAssertThrowsError(try Regex(pattern: "(\\e.?"))
    }

    func testMatch() {
        let regex = try! Regex(pattern: "\\d+")
        let results = regex.matches("Counter: 123")
        XCTAssertEqual(results.count, 1)
    }
}
