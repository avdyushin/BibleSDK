//
//  Book.swift
//  Woord
//
//  Created by Grigory Avdyushin on 16/02/2018.
//  Copyright © 2018 Grigory Avdyushin. All rights reserved.
//

import Foundation

public struct Book: Hashable, Equatable {

    public let id: Int
    public let title: String
    public let alt: String
    public let abbr: String
}
