//
//  DailyProviderTest.swift
//  WoordTests
//
//  Created by Grigory Avdyushin on 16/02/2018.
//  Copyright © 2018 Grigory Avdyushin. All rights reserved.
//

import XCTest
@testable import BibleSDK

class DailyProviderTest: XCTestCase {

    var provider: DailyProvider!

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        guard
            let path = Bundle(for: type(of: self)).path(forResource: "kjv_daily", ofType: "db"),
            let storage = try? SqliteStorage(filename: path) else {
                XCTFail("Can't create storage")
                return
        }

        provider = DailyProvider(
            storage: storage,
            bookProvider: BookProvider(storage: storage),
            abbreviation: try! BibleAbbreviation()
        )
    }
    
    override func tearDown() {
        provider = nil
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testDay() {
        let date = Date(timeIntervalSince1970: 123123123)
        let daily = try! DailyProvider.DayProvider.day(from: date)
        XCTAssertNotNil(daily)
        XCTAssertEqual(daily.month, 11)
        XCTAssertEqual(daily.day, 26)
        XCTAssertEqual(daily.morning, false)
    }

    func testFetchDaily() {
        let date = Date(timeIntervalSince1970: 123123123)
        let refs = provider.fetchDailyBookReferences(from: date)

        // 11|26|0|1|2 Кор 7:10 2 Цар 17:23 Притч 18:14 Иер 8:22 Ис 61:1-3 Матф 11:28-30
        // 11|26|0|1|Ac 8:35 Пс 147:3 *Ac 8:35 missed book
        XCTAssertEqual(refs.count, 13)
    }

    func testFetchDailyReading() {
        let date = Date(timeIntervalSince1970: 123123123)
        let reading = provider.fetchReading(from: date)
        XCTAssertEqual(reading.keys.count, 10)

        for (key, value) in reading {
            switch key.title {
            case "Исаия": XCTAssertEqual(value.count, 3)
            case "2-е Коринфянам": XCTAssertEqual(value.count, 1)
            case "Притчи": XCTAssertEqual(value.count, 1)
            case "Иеремия": XCTAssertEqual(value.count, 1)
            case "2-я Царств": XCTAssertEqual(value.count, 1)
            case "От Матфея": XCTAssertEqual(value.count, 3)
            default:
                ()
            }
        }
    }
}
