//
//  BibleSDK_iOS_Tests.swift
//  BibleSDK iOS Tests
//
//  Created by Grigory Avdyushin on 01/05/2019.
//

import XCTest
@testable import BibleSDK

@discardableResult func time<Result>(name: StaticString = #function, line: Int = #line, _ f: () -> Result) -> Result {
    let startTime = DispatchTime.now()
    let result = f()
    let endTime = DispatchTime.now()
    let diff = Double(endTime.uptimeNanoseconds - startTime.uptimeNanoseconds) / 1_000_000_000 as Double
    debugPrint("\(name) (line \(line)): \(diff) sec")
    return result
}

class BibleSDK_iOS_Tests: XCTestCase {

    func testVersion() {
        let v: Version = "kjv"
        XCTAssertEqual(v.abbr, "KJV")
    }

    func testDaily() {
        let b = BibleSDK()
        let refs = b.dailyContainer.dailyReferences(Date(timeIntervalSince1970: 123123123))
        XCTAssertEqual(refs.count, 14)
    }

    func testConversion() {
        let b = BibleSDK()
        let refs = b.dailyContainer.dailyReferences(Date(timeIntervalSince1970: 123123123))
        let conv = refs.map { b.bibleContainer.references(raw: $0) }
        XCTAssertEqual(refs.count, conv.count)
    }

    func testAllDailies() {
        let b = BibleSDK()
        let v = b.bibleContainer.availableVersions.first { $0.identifier == "kjv" }!
//        measure {
            for month in 1...12 {
                for day in 1...31 {
                    let refs = b.dailyContainer.dailyReferences(day: day, month: month)
                    let conv = refs.map { b.bibleContainer.references(raw: $0)! }
                    _ = conv.map { b.bibleContainer.verses(reference: $0.reference, version: v)}
                    XCTAssertEqual(refs.count, conv.count)
                }
            }
//        }
    }

    func testAllDailiesNonEmpty() {
        let b = BibleSDK()
        let v = b.bibleContainer.availableVersions.first { $0.identifier == "kjv" }!
        for month in 1...12 {
            for day in 1...31 {
                let refs = b.dailyContainer.dailyReferences(day: day, month: month)
                let conv = refs
                    .reduce([], { $0.contains($1) ? $0 : $0 + [$1]} )
                    .map { b.bibleContainer.references(raw: $0)! }
                let verses = conv
                    .map { b.bibleContainer.verses(reference: $0.reference, version: v) }
                    .filter { !$0.isEmpty }
                let dict = Dictionary(uniqueKeysWithValues: zip(conv, verses))
                if !refs.isEmpty {
                    for (key, verses) in dict {
                        XCTAssertFalse(verses.isEmpty, "Can't find \(key)")
                    }
                }
            }
        }
    }

    func testKJVDailyReading() {
        let b = BibleSDK()
        let v = b.bibleContainer.availableVersions.first { $0.identifier == "kjv" }!
        let reading = time {
            b.dailyReading(Date(timeIntervalSince1970: 123123123), version: v)
        }
        XCTAssertEqual(reading.keys.count, 14)
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
        let path = Bundle(for: type(of: self)).path(forResource: "rst", ofType: "db")!
        XCTAssertNoThrow(try b.bibleContainer.load(version: Version("rst"), path: path))
        let v = b.bibleContainer.availableVersions.first { $0.identifier == "rst" }!
        let reading = b.dailyReading(Date(timeIntervalSince1970: 123123123), version: v)
        XCTAssertEqual(reading.keys.count, 13)
    }

    func testAllDailiesInRST() {
        let b = BibleSDK()
        let path = Bundle(for: type(of: self)).path(forResource: "rst", ofType: "db")!
        try? b.bibleContainer.load(version: Version("rst"), path: path)
        let v = b.bibleContainer.availableVersions.first { $0.identifier == "rst" }!
        time {
            var total = 0
            for month in 1...12 {
                for day in 1...31 {
                    let refs = b.dailyContainer.dailyReferences(day: day, month: month)
                    let conv = refs.map { b.bibleContainer.references(raw: $0)! }
                    let verses = conv.map { b.bibleContainer.verses(reference: $0.reference, version: v)}
                    total += verses.count
                    XCTAssertEqual(refs.count, conv.count)
                }
            }
            XCTAssertEqual(total, 5089)
        }
    }
    
    func testAllDailiesInRSTV2() {
        let b = BibleSDK()
        let path = Bundle(for: type(of: self)).path(forResource: "rst", ofType: "db")!
        try? b.bibleContainer.load(version: Version("rst"), path: path)
        let v = b.bibleContainer.availableVersions.first { $0.identifier == "rst" }!
        time {
            var total = 0
            DispatchQueue.concurrentPerform(iterations: 12) { month in
                DispatchQueue.concurrentPerform(iterations: 31) { day in
                    let refs = b.dailyContainer.dailyReferences(day: day + 1, month: month + 1)
                    let conv = refs.map { b.bibleContainer.references(raw: $0)! }
                    let verses = conv.map { b.bibleContainer.verses(reference: $0.reference, version: v)}
                    total += verses.count
                    XCTAssertEqual(refs.count, conv.count)
                }
            }
            XCTAssertEqual(total, 5089)
        }
    }

    func testFetchByRefs() {
        let b = BibleSDK()
        let path = Bundle(for: type(of: self)).path(forResource: "rst", ofType: "db")!
        XCTAssertNoThrow(try b.bibleContainer.load(version: Version("rst"), path: path))
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

    func testSearchCount() {
        let b = BibleSDK()
        let c = time { b.bibleContainer.searchCount("For god") }
        debugPrint(c)
    }

    func testSearchIteratorChunks() {
        let b = BibleSDK()
        let i = b.bibleContainer.searchIterator("For god", version: "kjv", chunks: 8)
        let c = b.bibleContainer.searchCount("For god")["kjv"] ?? 0
        let counts = time { Set(i.map { $0.count }) }
        XCTAssertEqual(counts.sorted(), [c % 8, 8])
    }

    func testBibleSubscript() {
        let bibles = BibleSDK()
        let kjvBible = bibles["kjv"]!
        let genesisBook = kjvBible["gen"]
        XCTAssertEqual(genesisBook?.title, "Genesis")
    }

    func testSearchSurround() {
        let b = BibleSDK()
        let s = b.searchIterator("for god so loved", version: "kjv", chunks: 1, surround: ("<b>", "</b>"))
        let r = s.next()!.first!
        XCTAssertEqual(r.text, "<b>For</b> <b>God</b> <b>so</b> <b>loved</b> the world, that he gave his only begotten Son, that whosoever believeth in him should not perish, but have everlasting life.")
        XCTAssertEqual(r.bookName, "John")
    }
}
