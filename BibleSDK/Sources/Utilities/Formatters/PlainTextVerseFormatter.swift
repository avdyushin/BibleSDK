//
//  PlainTextVerseFormatter.swift
//  BibleSDK
//
//  Created by Grigory Avdyushin on 29/05/2019.
//

import Foundation

open class PlainTextVerseFormatter: VerseFormattable {

    static let regexpUnderline = try! Regex(pattern: "(\\s+|^)(_)(.+?)(\\2)")

    open class var underlineTemplate: String {
        return "$1$3"
    }

    open class func format(verse: Verse, style: VerseFormatStyle = .none) -> NSAttributedString {
        var result = verse.text.replacingOccurrences(of: "--", with: "—")
        result = regexpUnderline.replace(result, withTemplate: underlineTemplate)
        switch style {
        case .chapterAndVerse:
            result = "\(verse.chapter):\(verse.number) \(result)"
        case .verseNumber:
            result = "\(verse.number) \(result)"
        case .none:
            ()
        }
        return NSAttributedString(string: result)
    }

    open class func convert(verses: [Verse], style: VerseFormatStyle = .none) -> NSAttributedString {
        let result = verses
            .map { format(verse: $0, style: style).string }
            .joined(separator: "\n")
        return NSAttributedString(string: result)
    }
}
