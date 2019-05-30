//
//  AttributedStringVerseFormatter.swift
//  BibleSDK
//
//  Created by Grigory Avdyushin on 29/05/2019.
//

import UIKit
import Foundation

extension Array where Element == NSAttributedString {

    func joined(_ separator: Element) -> Element {
        let result = NSMutableAttributedString()
        var iter = makeIterator()
        if let first = iter.next() {
            result.append(first)
            while let next = iter.next() {
                result.append(separator)
                result.append(next)
            }
        }
        return result
    }
}

open class AttributedStringVerseFormatter: PlainTextVerseFormatter {

    open override class func format(verse: Verse, style: VerseFormatStyle = .none) -> NSAttributedString {
        let string = verse.text.replacingOccurrences(of: "--", with: "—")
        let result = NSMutableAttributedString(
            string: regexpUnderline.replace(string, withTemplate: underlineTemplate)
        )
        let attributes = [NSAttributedString.Key.foregroundColor: UIColor(hex: 0xaaaaaa)]
        switch style {
        case .chapterAndVerse:
            let string = NSAttributedString(string: "\(verse.chapter):\(verse.number) ", attributes: attributes)
            result.insert(string, at: 0)
        case .verseNumber:
            let string = NSAttributedString(string: "\(verse.number) ", attributes: attributes)
            result.insert(string, at: 0)
        case .none:
            ()
        }
        return result
    }

    open override class func convert(verses: [Verse], style: VerseFormatStyle = .none) -> NSAttributedString {
        return verses
            .map { format(verse: $0, style: style) }
            .joined(NSAttributedString(string: "\n"))
    }
}
