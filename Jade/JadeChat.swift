//
//  JadeChat.swift
//  JadeChat
//
//  Created by Thomas Gentry on 5/21/25.
//

import SwiftUI

@main
struct JadeChat: App {
    @State private var selectedTab = 0
    @State private var viewModel = ChatViewModel(mlxService: MLXService())
    
    init() {
        #if os(macOS)
        NSEvent.startMonitoringKeyDown()
        #endif
    }

    var body: some Scene {
        WindowGroup {
            #if os(macOS)
            TabView(selection: $selectedTab) {
                ChatView(viewModel: viewModel, selectedTab: $selectedTab)
                    .tag(0)
                    .tabItem { Text("Chat") }
                
                ScratchpadView(text: $viewModel.scratchpadText)
                    .tag(1)
                    .tabItem { Text("Scratchpad") }
            }
            // ✅ Use default styling on macOS (page style not supported)
            .tabViewStyle(DefaultTabViewStyle())
            #else
            TabView(selection: $selectedTab) {
                ChatView(viewModel: viewModel, selectedTab: $selectedTab)
                    .tag(0)

                ScratchpadView(text: $viewModel.scratchpadText)
                    .tag(1)
            }
            // ✅ Page style for iOS
            .tabViewStyle(.page(indexDisplayMode: .never))
            #endif
        }
    }
}
