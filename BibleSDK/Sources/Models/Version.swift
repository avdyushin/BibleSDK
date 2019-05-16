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

    // Pass "kjv.db"
    init(name: String) {
        precondition(!name.isEmpty)
        self.identifier = ((name as NSString).lastPathComponent as NSString).deletingPathExtension
        self.abbr = self.identifier.uppercased()
    }
}

extension Version: CustomStringConvertible {
    public var description: String {
        return identifier
    }
}
