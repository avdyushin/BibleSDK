//
//  Book.swift
//  Woord
//
//  Created by Grigory Avdyushin on 16/02/2018.
//  Copyright © 2018 Grigory Avdyushin. All rights reserved.
//

import Foundation

public struct Book: Hashable, Equatable {

    public typealias BookId = Int

    public let id: BookId
    public let index: UInt
    public let title: String
    public let alt: String
    public let abbr: String
    public var chaptersCount: UInt
}

extension Book {
    init(row: Row) {
        self.init(
            id: row["id"]!,
            index: row["idx"]!,
            title: row["title"]!,
            alt: row["alt"]!,
            abbr: row["abbr"]!,
            chaptersCount: row["chapters"]!
        )
    }
}
