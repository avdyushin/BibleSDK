//
//  BibleContainerTests.swift
//  BibleSDK iOS Tests
//
//  Created by Grigory Avdyushin on 09/05/2019.
//

import XCTest
@testable import BibleSDK

class BibleContainerTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let container = BibleContainer()
        XCTAssertEqual(container.bibles.count, 2)
        let bible = container.bibles.last!
        let book = bible.books.last!
        let verses = bible.verses(bookId: book.id)
        XCTAssertEqual(verses.count, 404)
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
}
