//
//  DailyProvider.swift
//  Woord
//
//  Created by Grigory Avdyushin on 16/02/2018.
//  Copyright © 2018 Grigory Avdyushin. All rights reserved.
//

import Foundation

struct DailyProvider {

    typealias DailyBookWithVerses = [Verse.Reference: [Verse]]

    struct DayProvider {

        enum DayProviderErrors: Error {
            case cantGetDateComponents
        }

        struct Daily {
            let month: Int
            let day: Int
            let morning: Bool
        }

        static func day(from date: Date) throws -> Daily {
            let components = Calendar.current.dateComponents([.month, .day, .hour], from: date)
            guard let month = components.month, let day = components.day, let hour = components.hour else {
                assertionFailure("Expected date components to be set")
                throw DayProviderErrors.cantGetDateComponents
            }

            return Daily(month: month, day: day, morning: hour > 6 && hour < 18)
        }
    }

    let storage: AsyncStorage
    let bookProvider: BookProvider
    let abbreviation: Abbreviation

    func fetchDailyBookReferences(from date: Date) -> [Verse.Reference] {
        guard let daily = try? DayProvider.day(from: date) else {
            assertionFailure("Expected daily to be set")
            return []
        }

        let query =
        """
        SELECT
            verses
        FROM
            kjv_bible_daily
        WHERE
            (month = \(daily.month)) AND
            (day = \(daily.day));
        """

        guard let rows = try? storage.fetch(query) else {
            assertionFailure("Expected daily verses to be fetched")
            return []
        }

        return rows
            .compactMap { $0["verses"]! }
            .flatMap { abbreviation.matches($0) }
            .reduce([], { $0.contains($1) ? $0 : $0 + [$1 ]})
            .compactMap { bookProvider.findBookReference(by: $0) }
    }

    func fetchReading(from date: Date) -> [Verse.Reference: [Verse]] {
        let references = fetchDailyBookReferences(from: date)
        guard references.isEmpty == false else {
            return [:]
        }

        let verses = references.flatMap { [bookProvider.findVerses(by: $0)] }
        let result = Dictionary(uniqueKeysWithValues: zip(references, verses))
        return result.filter { $0.value.count > 0 }
    }

    func findDailyReferences(_ date: Date, completion: @escaping (([Verse.Reference]) -> Void)) throws {

        let day = try DayProvider.day(from: date)
        let query = "SELECT verses FROM rst_bible_daily WHERE (month = \(day.month)) AND (day = \(day.day));"

        try storage.execute(query) { rows in

            let results = rows
                .compactMap { $0["verses"]! }
                .flatMap { self.abbreviation.matches($0) }
                .reduce([], { $0.contains($1) ? $0 : $0 + [$1] })
                .compactMap { self.bookProvider.findBookReference(by: $0) }

            completion(results)
        }
    }

    func fetchDailyVerses(_ date: Date, completion: @escaping (DailyBookWithVerses) -> Void) throws {

        try findDailyReferences(date) { references in
            guard references.isEmpty == false else {
                assertionFailure("Shouldn't goes here")
                completion([:])
                return
            }

            let verses = references.flatMap { [self.bookProvider.findVerses(by: $0)] }
            let result = Dictionary(uniqueKeysWithValues: zip(references, verses))

            completion(result.filter { $0.value.count > 0 })
        }
    }
//
//    func searchVersesAsBooks(_ string: String) -> [Verse.Reference: [Verse]] {
//        // Find whole books first
//        let books = bookProvider.findBooks(by: string)
//
//        guard books.count > 0 else {
//            let references = abbreviation.matches(string).compactMap { bookProvider.findBookReference(by: $0) }
//            guard references.isEmpty == false else {
//                return [:]
//            }
//            let verses = references.flatMap { [bookProvider.findVerses(by: $0)] }
//            let result = Dictionary(uniqueKeysWithValues: zip(references, verses))
//            return result.filter { $0.value.count > 0 }
//        }
//
//        let verses = books.flatMap { bookProvider.allVerses(book: $0) }
//        return Dictionary(grouping: verses) {
//            BookReference(book: $0.book, reference: Reference(book: $0.book.title, locations: []))
//        }
//    }

    let queue: OperationQueue = {
        let queue = OperationQueue()
        queue.name = "ru.avdyushin.SearchVersesByText"
        queue.maxConcurrentOperationCount = 1
        return queue
    }()

    @discardableResult
    func searchVersesByText_v3(_ string: String, completion: @escaping (Int, AnyIterator<[Verse]>) -> Void) -> Operation {
        queue.cancelAllOperations()
        let operation = BlockOperation()
        operation.addExecutionBlock {
            guard operation.isCancelled == false else {
                return
            }
            let (total, iterator) = self.bookProvider.findVersesIterator(search: string, step: 10)
            guard operation.isCancelled == false else {
                return
            }
            DispatchQueue.main.async {
                completion(total, iterator)
            }
        }
        queue.addOperation(operation)
        return operation
    }
//
//    func searchVersesPackResult(_ verses: [Verse]?) -> [Verse.Reference: [Verse]] {
//        guard let verses = verses else {
//            return [:]
//        }
//        return Dictionary(grouping: verses) {
//            BookReference(book: $0.book,
//                          reference: Reference(book: $0.book.title,
//                                               locations: [VerseLocation(chapters: [$0.chapter],
//                                                                         verses: [$0.number])]))
//        }
//    }
}
