//
//  Version.swift
//  BibleSDK
//
//  Created by Grigory Avdyushin on 15/05/2019.
//

import UIKit

public struct Version: Hashable {

    let identifier: String
    let abbr: String

    public init(_ name: String) {
        self.identifier = name
        self.abbr = self.identifier.uppercased()
    }
}

extension Version: CustomStringConvertible {
    public var description: String {
        return identifier
    }
}
