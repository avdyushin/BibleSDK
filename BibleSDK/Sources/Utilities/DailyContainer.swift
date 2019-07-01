//
//  DailyContainer.swift
//  BibleSDK
//
//  Created by Grigory Avdyushin on 15/05/2019.
//

/// Reference to the Month, Day and Morning/Evening
/// Used for the Daily Bible Verses
struct Daily {
    let month: Int
    let day: Int
    let morning: Bool
}

extension Daily {
    init(_ date: Date) {
        let components = Calendar.current.dateComponents([.month, .day, .hour], from: date)
        guard let month = components.month, let day = components.day, let hour = components.hour else {
            assertionFailure("Expected date components to be set")
            self.init(month: 1, day: 1, morning: true)
            return
        }
        self.init(month: month, day: day, morning: hour > 6 && hour < 18)
    }
}

class DailyContainer: Container<BaseSqliteStorage> {

    fileprivate let abbreviation: Abbreviation
    
    init(storage: BaseSqliteStorage, abbreviation: Abbreviation) {
        self.abbreviation = abbreviation
        super.init(storage: storage)
    }

    func dailyReferences(_ date: Date = Date()) -> [Verse.RawReference] {
        let daily = Daily(date)
        return dailyReferences(day: daily.day, month: daily.month)
    }

    func dailyReferences(day: Int, month: Int) -> [Verse.RawReference] {
        let query =
        """
        SELECT
            verses
        FROM
            kjv_bible_daily
        WHERE
            month = \(month) AND day = \(day);
        """

        do {
            return try storage
                .fetch(query)
                .flatMap { abbreviation.matches($0["verses"]!) }
                //.reduce([], { $0.contains($1) ? $0 : $0 + [$1] })
        } catch {
            debugPrint(error)
            return []
        }
    }
}
