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
import LaTeXSwiftUI

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

/// A view that displays a single message in the chat interface.
/// Supports different message roles (user, assistant, system) and media attachments.
struct MessageView: View {
    @ObservedObject var message: Message
    var viewModel: ChatViewModel
    @Binding var selectedTab: Int

    init(_ message: Message, viewModel: ChatViewModel, selectedTab: Binding<Int>) {
        self.message = message
        self.viewModel = viewModel
        self._selectedTab = selectedTab
    }

    var body: some View {
        switch message.role {
        case .user:
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
                                    renderSegment(segment)
                                }
                            }
                        } else {
                            Text(message.content)
                                .font(.body)
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
                            viewModel.scratchpadText = message.content
                            selectedTab = 1
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
                                renderSegment(segment)
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
                        Markdown(message.content)
                            .markdownTheme(.basic)
                            .font(.custom("Georgia", size: 16))
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
                            viewModel.scratchpadText = message.content
                            selectedTab = 1
                        }
                    }
            )

        case .system:
            Label {
                Text(message.content)
                    .font(.headline)
                    .foregroundColor(.secondary)
            } icon: {
                Image("Brandmark")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .clipShape(Circle())
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
    }

    @ViewBuilder
    private func renderSegment(_ segment: MessageSegment) -> some View {
        switch segment {
        case .markdown(let text):
            Markdown(text)
                .markdownTheme(.basic)
                .font(.custom("Georgia", size: 16))
                .padding(.bottom, 8)
                #if os(macOS)
                .background(Color(nsColor: .windowBackgroundColor))
                #else
                .background(Color(UIColor.secondarySystemBackground))
                #endif

        case .code(let code):
            CodeText(code)
                .padding(.vertical, 12)

        case .latex(let tex):
            LaTeX(#"$$\#(tex)$$"#)
                #if os(iOS)
                .font(UIFont(name: "Times New Roman", size: 18) ?? .systemFont(ofSize: 18))
                #elseif os(macOS)
                .font(NSFont.systemFont(ofSize: 20))
                #endif
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
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
