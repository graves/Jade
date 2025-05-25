//
//  MardownTheme.swift
//  Jade
//
//  Created by Thomas Gentry on 5/24/25.
//


import MarkdownUI

extension MarkdownTheme {
    static let jade = MarkdownTheme {
        Heading1 {
            FontWeight(.bold)
            FontFamily("Georgia")
            FontSize(20)
        }
        Paragraph {
            FontFamily("Georgia")
            FontSize(16)
            ForegroundColor(.primary)
        }
        CodeBlock {
            FontFamily("Menlo")
            FontSize(14)
            BackgroundColor(.init(.secondarySystemBackground))
            CornerRadius(6)
        }
    }
}
