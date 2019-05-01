//
//  BookProviderTest.swift
//  WoordTests
//
//  Created by Grigory Avdyushin on 16/02/2018.
//  Copyright © 2018 Grigory Avdyushin. All rights reserved.
//

import XCTest
@testable import BibleSDK

class BookProviderTest: XCTestCase {

    var provider: BookProvider!

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let path = Bundle(for: type(of: self)).path(forResource: "rst", ofType: "db")!
        let storage = try! SqliteStorage(filename: path)
        provider = BookProvider(storage: storage)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        provider = nil
        super.tearDown()
    }
    
    func testFindBook() {
        let book = provider.findBook(byName: "Быт")
        XCTAssertEqual(book?.id, 1)
        XCTAssertEqual(book?.title, "Бытие")
    }

    func testAllBooks() {
        let books = provider.allBooks
        XCTAssertEqual(books.count, 66)
        print(books[0])
    }

    func testFindReference() {
        let reference = provider.findBookReference(by: Verse.RawReference(bookName: "Исх", locations: []))
        XCTAssertEqual(reference?.book.id, 2)
        XCTAssertEqual(reference?.book.title, "Исход")
    }

    func testFindChunks() {
        let text = "Благодать"
        let total = provider.findVersesTextChunksCount(search: text)
        XCTAssertEqual(total, 84)

        let next = provider.findVersesTextChunks(search: text, start: 0, count: 10)
        XCTAssertEqual(next.count, 10)
    }

    func testFindIterator() {
        let text = "Благодать"
        let (_, iterator1) = provider.findVersesIterator(search: text, step: 10)
        let counts1 = Set(iterator1.compactMap { return $0.count })
        XCTAssertEqual(counts1, [10, 4])

        let (_, iterator2) = provider.findVersesIterator(search: text, step: 9)
        let counts2 = Set(iterator2.compactMap { return $0.count })
        XCTAssertEqual(counts2, [9, 3])
    }
}
