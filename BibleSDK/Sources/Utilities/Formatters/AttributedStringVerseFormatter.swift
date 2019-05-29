//
//  AttributedStringVerseFormatter.swift
//  BibleSDK
//
//  Created by Grigory Avdyushin on 29/05/2019.
//

import UIKit
import Foundation

public class AttributedStringVerseFormatter: PlainTextVerseFormatter {

    public override class func format(verse: Verse, style: VerseFormatStyle = .none) -> NSAttributedString {
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
        // Dynamic font support
//        result.addAttributes(
//            [
//                NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .subheadline)
//            ],
//            range: NSRange.init(location: 0, length: result.length)
//        )
        return result
    }

    public override class func convert(verses: [Verse], style: VerseFormatStyle = .none) -> NSAttributedString {
        let result = NSMutableAttributedString()
        verses.forEach {
            result.append(format(verse: $0, style: style))
        }
        return result
    }
}
