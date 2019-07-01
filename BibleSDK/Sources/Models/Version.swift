//
//  Version.swift
//  BibleSDK
//
//  Created by Grigory Avdyushin on 15/05/2019.
//

import UIKit

/// Bible Version object
///
/// Represents different Bible versions (translations)
public struct Version: Hashable, ExpressibleByStringLiteral {

    /// An identifier of the Version
    ///
    /// Examples of identifies:
    /// - `KJV:en_US`
    /// - `RST:ru_RU`
    public let identifier: String
    /// A title of the Version
    public let name: String
    /// A local of the Version
    public let locale: String?

    /// Inits Version with given identifier in format `TITLE:LOCALE`
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

    /// Allows string literals
    ///
    ///     let version: Version = "KJV:en_US"
    public init(stringLiteral value: String) {
        self.init(value)
    }
}

extension Version: CustomStringConvertible {
    public var description: String {
        return "\(identifier)(\(name)) \(locale ?? "none")"
    }
}
