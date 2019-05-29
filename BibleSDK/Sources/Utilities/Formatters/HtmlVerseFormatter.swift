//
//  HtmlVerseFormatter.swift
//  BibleSDK
//
//  Created by Grigory Avdyushin on 29/05/2019.
//

import UIKit

public class HtmlVerseFormatter: PlainTextVerseFormatter {

    public class var headerTemplate: String {
        return """
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
    }

    public class var footerTemplate: String {
        return "</body></html>"
    }

    override class var underlineTemplate: String {
        return "$1<i>$3</i>"
    }

    public override class func convert(verses: [Verse], style: VerseFormatStyle = .none) -> NSAttributedString {
        let string = verses
            .map { "<p>\(format(verse: $0, style: style).string)</p>" }
            .joined(separator: "")

        let htmlString = "\(HtmlVerseFormatter.headerTemplate)\(string)\(HtmlVerseFormatter.footerTemplate)"
        let attributed = try! NSMutableAttributedString(
            data: htmlString.data(using: String.Encoding.utf8)!,
            options: [.documentType: NSAttributedString.DocumentType.html,
                      .characterEncoding: String.Encoding.utf8.rawValue],
            documentAttributes: nil
        )
        let results = NSMutableAttributedString(attributedString: attributed)
        // Dynamic font support
//        let font = UIFontMetrics(forTextStyle: .subheadline)
//            .scaledFont(for: UIFont(name: "Georgia", size: 20)!)
//        // TODO: Fix locale
//        results.addAttributes(
//            [
//                NSAttributedString.Key.init("locale"): "ru",
//                NSAttributedString.Key.font: font
//            ],
//            range: NSRange.init(location: 0, length: attributed.length)
//        )
        return results
    }
}
