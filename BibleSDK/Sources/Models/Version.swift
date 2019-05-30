//
//  Version.swift
//  BibleSDK
//
//  Created by Grigory Avdyushin on 15/05/2019.
//

import UIKit

public struct Version: Hashable, ExpressibleByStringLiteral {

    public let identifier: String
    public let name: String
    public let locale: String?

    public init(_ identifier: String) {
        let components = identifier.split(separator: ":").map(String.init)
        if components.count == 2 {
            self.identifier = components[0]
            self.name = components[0].uppercased()
            self.locale = components[1]
        } else {
            self.identifier = identifier.lowercased()
            self.name = identifier.uppercased()
            self.locale = nil
        }
    }

    public init(stringLiteral value: String) {
        self.init(value)
    }
}

extension Version: CustomStringConvertible {
    public var description: String {
        return "id: \(identifier) name: \(name) locale: \(locale ?? "none"))"
    }
}
