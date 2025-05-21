//
//  MessageContentParserService.swift
//  HowSheWorks
//
//  Created by Thomas Gentry on 5/20/25.
//
import Foundation

/// Represents a parsed segment of a chat message: either Markdown or a code block.
enum MessageSegment: Identifiable {
    case markdown(String)
    case code(String)

    var id: UUID { UUID() }
}

/// Parses a message string into alternating Markdown and code block segments.
///
/// - Parameter content: The full message string.
/// - Returns: An array of `MessageSegment`s, separated by Markdown and code blocks.
func parseMessageContent(_ content: String) -> [MessageSegment] {
    var segments: [MessageSegment] = []
    let lines = content.components(separatedBy: "\n")
    var isInCodeBlock = false
    var currentCode = ""
    var currentMarkdown = ""

    for line in lines {
        if line.starts(with: "```") {
            if isInCodeBlock {
                // Close code block
                segments.append(.code(currentCode.trimmingCharacters(in: .whitespacesAndNewlines)))
                currentCode = ""
            } else {
                // Flush any pending markdown before code block
                if !currentMarkdown.isEmpty {
                    segments.append(.markdown(currentMarkdown.trimmingCharacters(in: .whitespacesAndNewlines)))
                    currentMarkdown = ""
                }
            }
            isInCodeBlock.toggle()
        } else {
            if isInCodeBlock {
                currentCode += line + "\n"
            } else {
                currentMarkdown += line + "\n"
            }
        }
    }

    // Append whatever remains
    if !currentMarkdown.isEmpty {
        segments.append(.markdown(currentMarkdown.trimmingCharacters(in: .whitespacesAndNewlines)))
    }

    return segments
}
