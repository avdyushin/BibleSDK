//
//  SearchStringVerseConverter.swift
//  Woord
//
//  Created by Grigory Avdyushin on 29/05/2019.
//  Copyright © 2019 Grigory Avdyushin. All rights reserved.
//

import UIKit

public class SearchResultVerseFormatter: AttributedStringVerseFormatter {

    static let regexpSpan = try! Regex(pattern: ".*?<span>(.*?)<\\/span>.*?", options: [.caseInsensitive])

    public override class func format(verse: Verse, style: VerseFormatStyle = .none) -> NSAttributedString {
        let string = AttributedStringVerseFormatter.format(verse: verse, style: style).string
        let result = NSMutableAttributedString(string: string)

        regexpSpan.matches(result.string, options: [], range: NSRange(string.startIndex..., in: string)).forEach {
            result.addAttribute(
                NSAttributedString.Key.backgroundColor,
                value: UIColor(hex: 0xfff2a8) as Any,
                range: $0.range(at: 1)
            )
        }

        while(result.string.contains("<span>") || result.string.contains("</span>")) {
            if let range = result.string.range(of: "<span>") {
                result.replaceCharacters(in: NSRange(range, in: result.string), with: "")
            }
            if let range = result.string.range(of: "</span>") {
                result.replaceCharacters(in: NSRange(range, in: result.string), with: "")
            }
        }
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
