//
//  Version.swift
//  BibleSDK
//
//  Created by Grigory Avdyushin on 15/05/2019.
//

import UIKit

public struct Version: Hashable, ExpressibleByStringLiteral {

    let identifier: String
    let abbr: String
    let locale: String?

    public init(_ name: String, locale: String? = nil) {
        self.identifier = name.lowercased()
        self.abbr = self.identifier.uppercased()
        self.locale = locale
    }

    public init(stringLiteral value: String) {
        self.init(value)
    }
}

extension Version: CustomStringConvertible {
    public var description: String {
        return "\(identifier) \(abbr) \(String(describing: locale))"
    }
}
