//
//  StorageTest.swift
//  WoordTests
//
//  Created by Grigory Avdyushin on 16/02/2018.
//  Copyright © 2018 Grigory Avdyushin. All rights reserved.
//

import XCTest
@testable import BibleSDK

class StorageTest: XCTestCase {

    var storage: AsyncStorage!

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let path = Bundle(for: type(of: self)).path(forResource: "rst", ofType: "db")!
        storage = try! SqliteStorage(filename: path)
    }
    
    override func tearDown() {
        storage = nil
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testNoThorws() {
        guard let path = Bundle(for: type(of: self)).path(forResource: "rst", ofType: "db") else {
            XCTFail("Can't find rst.db!")
            return
        }

        XCTAssertNoThrow(try SqliteStorage(filename: path))
    }

    func testFetch() {
        let rows = try? storage.fetch("select * from rst_bible_books limit 1;")
        XCTAssertEqual(rows?.count, 1)

        guard let row = rows?.first else {
            XCTFail()
            return
        }

        XCTAssertEqual(row["id"], 1)
        XCTAssertEqual(row["book"], "Бытие")
        XCTAssertEqual(row["alt"], "Быт")
        XCTAssertEqual(row["abbr"], "Быт")
    }

    func testCustomFunction() {
        let str = "быт"
        let rows = try? storage.fetch("select * from rst_bible_books where UTF8_UPPER(abbr) == '\(str.uppercased())';")

        guard let row = rows?.first else {
            XCTFail()
            return
        }

        XCTAssertEqual(row["id"], 1)
        XCTAssertEqual(row["book"], "Бытие")
        XCTAssertEqual(row["alt"], "Быт")
        XCTAssertEqual(row["abbr"], "Быт")
    }

    func testCount() {
        let row = try? storage.fetch("select COUNT(*) from rst_bible_books").first
        let count: Int = row??["COUNT(*)"] ?? 0
        XCTAssertEqual(count, 66)
    }

    func testAsync() {
        let expectation = XCTestExpectation(description: "Wait for completion")
        try! storage.execute("select COUNT(*) from rst_bible") { rows in
            let count: Int? = rows.first?["COUNT(*)"]
            XCTAssertEqual(count, 31349)
            expectation.fulfill()
        }
        self.wait(for: [expectation], timeout: 10)
    }
}
