//
//  AttributedStringVerseFormatter.swift
//  BibleSDK
//
//  Created by Grigory Avdyushin on 29/05/2019.
//

import UIKit
import Foundation

open class AttributedStringVerseFormatter: PlainTextVerseFormatter {

    open override class func format(verse: Verse, style: VerseFormatStyle = .none) -> NSAttributedString {
        let result = NSMutableAttributedString(
            attributedString: PlainTextVerseFormatter.format(verse: verse, style: style)
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
        let result = NSMutableAttributedString()
        verses.forEach {
            result.append(format(verse: $0, style: style))
        }
        return result
    }
}
