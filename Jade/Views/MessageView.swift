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
    var viewModel: ChatViewModel
    @Binding var selectedTab: Int

    /// Creates a message view
    /// - Parameter message: The message model to display
    init(_ message: Message, viewModel: ChatViewModel, selectedTab: Binding<Int>) {
        self.message = message
        self.viewModel = viewModel
        self._selectedTab = selectedTab
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
                    #if os(iOS)
                    .contextMenu {
                        Button(action: {
                            UIPasteboard.general.string = message.content
                        }) {
                            Label("Copy Message", systemImage: "doc.on.doc")
                        }
                    }
                    #elseif os(macOS)
                    .contextMenu {
                        Button(action: {
                            NSPasteboard.general.clearContents()
                            NSPasteboard.general.setString(message.content, forType: .string)
                        }) {
                            Label("Copy Message", systemImage: "doc.on.doc")
                        }
                    }
                    #endif
                }
            }
            .gesture(
                DragGesture(minimumDistance: 30)
                    .onEnded { value in
                        if value.translation.width < -50 {
                            // Left swipe detected
                            viewModel.scratchpadText = message.content
                            selectedTab = 1 // switch to scratchpad
                        }
                    }
            )

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
                        .padding(12)
                        #if os(macOS)
                        .background(Color(.windowBackgroundColor))
                        #else
                        .background(Color(UIColor.secondarySystemBackground))
                        #endif
                        .cornerRadius(16)
                    } else {
                        // While streaming, show content as Markdown only
                        Markdown(message.content)
                            .markdownTheme(.gitHub)
                            .padding(12)
                            #if os(macOS)
                            .background(Color(.windowBackgroundColor))
                            #else
                            .background(Color(UIColor.secondarySystemBackground))
                            #endif
                            .cornerRadius(16)
                    }
                }
                .textSelection(.enabled)
                #if os(iOS)
                .contextMenu {
                    Button(action: {
                        UIPasteboard.general.string = message.content
                    }) {
                        Label("Copy Message", systemImage: "doc.on.doc")
                    }
                }
                #elseif os(macOS)
                .contextMenu {
                    Button(action: {
                        NSPasteboard.general.clearContents()
                        NSPasteboard.general.setString(message.content, forType: .string)
                    }) {
                        Label("Copy Message", systemImage: "doc.on.doc")
                    }
                }
                #endif

                Spacer()
            }
            .gesture(
                DragGesture(minimumDistance: 30)
                    .onEnded { value in
                        if value.translation.width < -50 {
                            // Left swipe detected
                            viewModel.scratchpadText = message.content
                            selectedTab = 1 // switch to scratchpad
                        }
                    }
            )

        case .system:
            Label {
                Text(message.content)
                    .font(.headline)
                    .foregroundColor(.secondary)
            } icon: {
                Image("Brandmark") // Your custom asset name
                    .resizable()
                    .frame(width: 20, height: 20) // Adjust size as needed
                    .clipShape(Circle()) // Optional for round logos
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
    }
}

#Preview {
    MessageViewPreviewWrapper()
}

private struct MessageViewPreviewWrapper: View {
    @State private var selectedTab = 0
    private let vm = ChatViewModel(mlxService: MLXService())

    var body: some View {
        VStack(spacing: 20) {
            MessageView(
                .system("You are a helpful assistant."),
                viewModel: vm,
                selectedTab: $selectedTab
            )

            MessageView(
                .user(
                    "Here's a photo",
                    images: [URL(string: "https://picsum.photos/200")!]
                ),
                viewModel: vm,
                selectedTab: $selectedTab
            )

            MessageView(
                .assistant("I see your photo!"),
                viewModel: vm,
                selectedTab: $selectedTab
            )
        }
        .padding()
    }
}
