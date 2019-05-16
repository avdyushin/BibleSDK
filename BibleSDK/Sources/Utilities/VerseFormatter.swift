//
//  VerseFormatter.swift
//  Woord
//
//  Created by Grigory Avdyushin on 14/03/2018.
//  Copyright © 2018 Grigory Avdyushin. All rights reserved.
//

import UIKit
import Foundation

public enum VerseFormatStyle {
    public enum NumberFormatStyle {
        case chapter
        case verse
    }

    case highlight(String?)
    case numbers(NumberFormatStyle)
    case version(Version)
}

public protocol VerseConverterDelegate {
    static func format(verse: Verse, styles: [VerseFormatStyle]) -> NSAttributedString
    static func convert(verses: [Verse], styles: [VerseFormatStyle]) -> NSAttributedString
}

public enum HtmlVerseConverter: VerseConverterDelegate {
    static let header = """
        <!DOCTYPE html><html><head>
        <meta http-equiv='Content-Type' content='text/html; charset=utf-8'>
        <style type='text/css'>
        * {
            text-rendering: optimizeLegibility;
        }
        html {
            -webkit-hyphens: auto;
        }
        body {
            font: 15pt Georgia;
            line-height: 1.8;
            color: #555555;
            background-color: #ffffff;
        }
        small {
            color: #999999;
        }
        span {
            background-color: #fff2a8;
        }
        </style></head><body>
        """
    static let footer = "</body></html>"

    static let regexpUnderline = try! Regex(pattern: "(\\s+|^)(_)(.+?)(\\2)")

    public static func format(verse: Verse, styles: [VerseFormatStyle] = []) -> NSAttributedString {
        var result = verse.text.replacingOccurrences(of: "--", with: "—")
        result = regexpUnderline.replace(result, withTemplate: "$1<i>$3</i>")
        styles.forEach {
            switch $0 {
            case .highlight(let string):
                if let string = string {
                    let regexpHighlight = try! Regex(pattern: "(\(string))", options: [.caseInsensitive])
                    result = regexpHighlight.replace(result, withTemplate: "<span>$1</span>")
                }
            case .numbers(let style):
                switch style {
                case .chapter:
                    result = "<small>\(verse.chapter):\(verse.number)</small> \(result)"
                case .verse:
                    result = "<small>\(verse.number)</small> \(result)"
                }
            case .version: break
            }
        }
        return NSAttributedString(string: result)
    }

    public static func convert(verses: [Verse], styles: [VerseFormatStyle] = []) -> NSAttributedString {
        let string = verses.compactMap {
            return "<p>\(format(verse: $0, styles: styles).string)</p>"
        }.joined(separator: "")

        let htmlString = "\(HtmlVerseConverter.header)\(string)\(HtmlVerseConverter.footer)"
        let attributed = try! NSMutableAttributedString(data: htmlString.data(using: String.Encoding.utf8)!,
                                                        options: [.documentType: NSAttributedString.DocumentType.html,
                                                                  .characterEncoding: String.Encoding.utf8.rawValue],
                                                        documentAttributes: nil)
        let results = NSMutableAttributedString(attributedString: attributed)
        // Dynamic font support
        let font = UIFontMetrics(forTextStyle: .subheadline)
            .scaledFont(for: UIFont(name: "Georgia", size: 20)!)
        // TODO: Fix locale
        results.addAttributes([
            NSAttributedString.Key.init("locale"): "ru",
            NSAttributedString.Key.font: font
        ], range: NSRange.init(location: 0, length: attributed.length))
        return results
    }
}

public enum StringVerseConverter: VerseConverterDelegate {

    static let regexpUnderline = try! Regex(pattern: "(\\s+|^)(_)(.+?)(\\2)")

    public static func format(verse: Verse, styles: [VerseFormatStyle]) -> NSAttributedString {
        var string = verse.text.replacingOccurrences(of: "--", with: "—")
        string = regexpUnderline.replace(string, withTemplate: "$1$3")
        let result = NSMutableAttributedString(string: string)
        styles.forEach {
            switch $0 {
            case .highlight(let string):
                if let string = string {
                    let regexpHighlight = try! Regex(pattern: "(\(string))", options: [.caseInsensitive])
                    regexpHighlight.enumerate(in: result.string) { (matches, flags, stop) in
                        guard let range = matches?.range else {
                            return
                        }
                        result.addAttribute(NSAttributedString.Key.backgroundColor,
                                            value: UIColor(hex: 0xfff2a8) as Any,
                                            range: range)
                    }
                }
            case .numbers(let style):
                let attributes = [NSAttributedString.Key.foregroundColor: UIColor(hex: 0xaaaaaa)]
                switch style {
                case .chapter:
                    let string = NSAttributedString(string: "\(verse.chapter):\(verse.number) ", attributes: attributes)
                    result.insert(string, at: 0)
                case .verse:
                    let string = NSAttributedString(string: "\(verse.number) ", attributes: attributes)
                    result.insert(string, at: 0)
                }
            case .version: break
            }
        }
        // Dynamic font support
        result.addAttributes([
            NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .subheadline)
        ], range: NSRange.init(location: 0, length: result.length))
        return result
    }

    public static func convert(verses: [Verse], styles: [VerseFormatStyle]) -> NSAttributedString {
        let result = NSMutableAttributedString()
        verses.forEach {
            result.append(format(verse: $0, styles: styles))
        }
        return result
    }
}

public enum PlainTextVerseConverter: VerseConverterDelegate {

    static let regexpUnderline = try! Regex(pattern: "(\\s+|^)(_)(.+?)(\\2)")

    public static func format(verse: Verse, styles: [VerseFormatStyle]) -> NSAttributedString {
        var result = verse.text.replacingOccurrences(of: "--", with: "—")
        result = regexpUnderline.replace(result, withTemplate: "$1$3")
        styles.forEach {
            switch $0 {
            case .highlight:
                // TODO: Wrap highlight string with '*'
                () // Not supported yet
            case .numbers(let style):
                switch style {
                case .chapter:
                    result = "\(verse.chapter):\(verse.number) \(result)"
                case .verse:
                    result = "\(verse.number) \(result)"
                }
            case .version: break
            }
        }
        return NSAttributedString(string: result)
    }

    public static func convert(verses: [Verse], styles: [VerseFormatStyle]) -> NSAttributedString {
        let result = verses
            .map { format(verse: $0, styles: styles).string }
            .joined(separator: "\n")

        return NSAttributedString(string: result)
    }
}

public struct VerseConverter<Converter: VerseConverterDelegate> {
    public func convert(verses: [Verse], styles: [VerseFormatStyle]) -> NSAttributedString {
        return Converter.convert(verses: verses, styles: styles)
    }
}
