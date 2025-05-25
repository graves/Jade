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
    case latex(String)

    var id: UUID { UUID() }
}

/// Parses a message string into alternating Markdown and code block segments.
///
/// - Parameter content: The full message string.
/// - Returns: An array of `MessageSegment`s, separated by Markdown and code blocks.
func parseMessageContent(_ content: String) -> [MessageSegment] {
    var segments: [MessageSegment] = []
    var buffer = ""
    var isInLatexBlock = false
    var isInCodeBlock = false

    let lines = content.components(separatedBy: "\n")

    for line in lines {
        if line.starts(with: "```") {
            if isInCodeBlock {
                segments.append(.code(buffer.trimmingCharacters(in: .whitespacesAndNewlines)))
                buffer = ""
            } else if !buffer.isEmpty {
                segments.append(.markdown(buffer.trimmingCharacters(in: .whitespacesAndNewlines)))
                buffer = ""
            }
            isInCodeBlock.toggle()
        } else if line.trimmingCharacters(in: .whitespacesAndNewlines) == "$$" {
            if isInLatexBlock {
                segments.append(.latex(buffer.trimmingCharacters(in: .whitespacesAndNewlines)))
                buffer = ""
            } else if !buffer.isEmpty {
                segments.append(.markdown(buffer.trimmingCharacters(in: .whitespacesAndNewlines)))
                buffer = ""
            }
            isInLatexBlock.toggle()
        } else {
            buffer += line + "\n"
        }
    }

    // Flush remaining
    if !buffer.isEmpty {
        let type: MessageSegment = isInCodeBlock ? .code(buffer) :
                                isInLatexBlock ? .latex(buffer) :
                                .markdown(buffer)
        segments.append(type)
    }

    return segments
}
