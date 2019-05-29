//
//  VerseFormatter.swift
//  Woord
//
//  Created by Grigory Avdyushin on 14/03/2018.
//  Copyright © 2018 Grigory Avdyushin. All rights reserved.
//

import Foundation

public enum VerseFormatStyle {
    case none
    case chapterAndVerse
    case verseNumber
}

public protocol VerseFormattable: class {
    static func format(verse: Verse, style: VerseFormatStyle) -> NSAttributedString
    static func convert(verses: [Verse], style: VerseFormatStyle) -> NSAttributedString
}

public struct VerseFormatter<Formatter: VerseFormattable> {
    public init() { }
    public func convert(verses: [Verse], style: VerseFormatStyle = .none) -> NSAttributedString {
        return Formatter.convert(verses: verses, style: style)
    }
}
