//
//  Regex.swift
//  Woord
//
//  Created by Grigory Avdyushin on 16/02/2018.
//  Copyright © 2018 Grigory Avdyushin. All rights reserved.
//

import Foundation

/// Helper object to work with Regular Expressions
public struct Regex {

    private let expression: NSRegularExpression

    public init(pattern: String, options: NSRegularExpression.Options = []) throws {
        expression = try NSRegularExpression(pattern: pattern, options: options)
    }

    public func matches(_ string: String,
                        options: NSRegularExpression.MatchingOptions = [],
                        range: NSRange? = nil) -> [NSTextCheckingResult] {

        let range = range ?? NSRange(string.startIndex..., in: string)
        return expression.matches(in: string, options: options, range: range)
    }

    public func enumerate(in string: String,
                          options: NSRegularExpression.MatchingOptions = [],
                          range: NSRange? = nil,
                          using block: (NSTextCheckingResult?, NSRegularExpression.MatchingFlags, UnsafeMutablePointer<ObjCBool>) -> Void) {
        let range = range ?? NSRange(string.startIndex..., in: string)
        expression.enumerateMatches(in: string, options: options, range: range, using: block)
    }

    public func replace(_ string: String,
                        withTemplate template: String,
                        options: NSRegularExpression.MatchingOptions = [],
                        range: NSRange? = nil) -> String {

        let range = range ?? NSRange(string.startIndex..., in: string)
        return expression.stringByReplacingMatches(in: string,
                                                   options: options,
                                                   range: range,
                                                   withTemplate: template)
    }
}

public extension NSTextCheckingResult {

    func resultValue<T>(_ string: String, withName name: String) -> T? {
        if T.self == String.self {
            return stringValue(string, withName: name) as? T
        } else if T.self == Int.self {
            return intValue(string, withName: name) as? T
        } else {
            return nil
        }
    }

    func stringValue(_ string: String, withName name: String) -> String? {
        let range = self.range(withName: name)
        guard range.location != NSNotFound else {
            return nil
        }
        return String(string[Range(range, in: string)!])
    }

    func intValue(_ string: String, withName name: String) -> Int? {
        let range = self.range(withName: name)
        guard range.location != NSNotFound else {
            return nil
        }
        return Int(string[Range(range, in: string)!])
    }
}
