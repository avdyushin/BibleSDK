//
//  Book.swift
//  Woord
//
//  Created by Grigory Avdyushin on 16/02/2018.
//  Copyright © 2018 Grigory Avdyushin. All rights reserved.
//

import Foundation

/// A Bible's Book object
public struct Book: Hashable, Equatable {

    public typealias BookId = Int

    /// An internal identifier of the Book
    public let id: BookId
    /// An index of order
    public let index: UInt
    /// A full title of the Book
    public let title: String
    /// An alternative title of the Book
    public let alt: String
    /// An abbriviation of the Book
    public let abbr: String
    /// A chapters count of the Book
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
