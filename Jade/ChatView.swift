//
//  ChatView.swift
//  MLXChatExample
//
//  Created by İbrahim Çetin on 20.04.2025.
//

import AVFoundation
import AVKit
import SwiftUI

/// Main chat interface view that manages the conversation UI and user interactions.
/// Displays messages, handles media attachments, and provides input controls.
struct ChatView: View {
    /// View model that manages the chat state and business logic
    @Bindable private var vm: ChatViewModel
    @Binding var selectedTab: Int

    /// Initializes the chat view with a view model
    /// - Parameter viewModel: The view model to manage chat state
    init(viewModel: ChatViewModel, selectedTab: Binding<Int>) {
        self.vm = viewModel
        self._selectedTab = selectedTab
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Display conversation history
                ConversationView(messages: vm.messages, viewModel: vm, selectedTab: $selectedTab)

                Divider()

                // Show media previews if attachments are present
                if !vm.mediaSelection.isEmpty {
                    MediaPreviewsView(mediaSelection: vm.mediaSelection)
                }

                // Input field with send and media attachment buttons
                PromptField(
                    prompt: $vm.prompt,
                    sendButtonAction: vm.generate,
                    // Only show media button for vision-capable models
                    mediaButtonAction: vm.selectedModel.isVisionModel
                        ? {
                            vm.mediaSelection.isShowing = true
                        } : nil
                )
                .padding()
            }
            .navigationTitle("Jade")
            .toolbar {
                ChatToolbarView(vm: vm)
            }
            // Handle media file selection
            .fileImporter(
                isPresented: $vm.mediaSelection.isShowing,
                allowedContentTypes: [.image, .movie],
                onCompletion: vm.addMedia
            )
        }
    }
}

#Preview {
    ChatViewPreviewWrapper()
}

private struct ChatViewPreviewWrapper: View {
    @State private var selectedTab = 0

    var body: some View {
        ChatView(viewModel: ChatViewModel(mlxService: MLXService()), selectedTab: $selectedTab)
    }
}
