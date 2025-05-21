//
//  MessageView.swift
//  MLXChatExample
//
//  Created by İbrahim Çetin on 20.04.2025.
//

import AVKit
import SwiftUI
import MarkdownUI
import HighlightSwift

/// A view that displays a single message in the chat interface.
/// Supports different message roles (user, assistant, system) and media attachments.
struct MessageView: View {
    /// The message to be displayed
    @ObservedObject var message: Message

    /// Creates a message view
    /// - Parameter message: The message model to display
    init(_ message: Message) {
        self.message = message
    }

    var body: some View {
        switch message.role {
        case .user:
            // User messages are right-aligned with blue background
            HStack {
                Spacer()
                VStack(alignment: .trailing, spacing: 8) {
                    if let firstImage = message.images.first {
                        AsyncImage(url: firstImage) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(maxWidth: 250, maxHeight: 200)
                        .clipShape(.rect(cornerRadius: 12))
                    }

                    if let firstVideo = message.videos.first {
                        VideoPlayer(player: AVPlayer(url: firstVideo))
                            .frame(width: 250, height: 340)
                            .clipShape(.rect(cornerRadius: 12))
                    }

                    Group {
                        if message.isComplete {
                            VStack(alignment: .leading, spacing: 4) {
                                let segments = parseMessageContent(message.content)
                                ForEach(segments) { segment in
                                    switch segment {
                                    case .markdown(let text):
                                        Text(text)
                                            .padding(.bottom, 8)
                                    case .code(let code):
                                        CodeText(code)
                                            .padding(.vertical, 12)
                                    }
                                }
                            }
                        } else {
                            // While streaming, show content as Markdown only
                            Text(message.content)
                        }
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(.tint, in: .rect(cornerRadius: 16))
                    .textSelection(.enabled)
                }
            }

        case .assistant:
            HStack {
                Group {
                    if message.isComplete {
                        VStack(alignment: .leading, spacing: 4) {
                            let segments = parseMessageContent(message.content)
                            ForEach(segments) { segment in
                                switch segment {
                                case .markdown(let text):
                                    Markdown(text)
                                        .markdownTheme(.gitHub)
                                        .padding(.bottom, 8)
                                case .code(let code):
                                    CodeText(code)
                                        .padding(.vertical, 12)
                                }
                            }
                        }
                    } else {
                        // While streaming, show content as Markdown only
                        Markdown(message.content)
                            .markdownTheme(.gitHub)
                    }
                }
                .textSelection(.enabled)

                Spacer()
            }

        case .system:
            Label(message.content, systemImage: "desktopcomputer")
                .font(.headline)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .center)
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        MessageView(.system("You are a helpful assistant."))

        MessageView(
            .user(
                "Here's a photo",
                images: [URL(string: "https://picsum.photos/200")!]
            )
        )

        MessageView(.assistant("I see your photo!"))
    }
    .padding()
}
