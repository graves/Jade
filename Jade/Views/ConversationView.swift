//
//  ConversationView.swift
//  MLXChatExample
//
//  Created by İbrahim Çetin on 20.04.2025.
//

import SwiftUI

/// Displays the chat conversation as a scrollable list of messages.
struct ConversationView: View {
    let messages: [Message]
    let viewModel: ChatViewModel
    @Binding var selectedTab: Int

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(messages) { message in
                    MessageView(message, viewModel: viewModel, selectedTab: $selectedTab)
                        .padding(.horizontal, 12)
                }
            }
        }
        .padding(.vertical, 8)
        .defaultScrollAnchor(.bottom, for: .sizeChanges)
    }
}

#Preview {
    ConversationPreviewWrapper()
}

private struct ConversationPreviewWrapper: View {
    @State private var selectedTab = 0
    private let viewModel = ChatViewModel(mlxService: MLXService())

    var body: some View {
        ConversationView(
            messages: SampleData.conversation,
            viewModel: viewModel,
            selectedTab: $selectedTab
        )
    }
}
