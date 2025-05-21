//
//  ScratchpadView.swift
//  Jade
//
//  Created by Thomas Gentry on 5/21/25.
//
import SwiftUI

struct ScratchpadView: View {
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading) {
            Text("Scratchpad")
                .font(.title2.bold())
                .padding(.bottom)

            TextEditor(text: $text)
                .padding()
                #if os(iOS)
                .background(Color(UIColor.secondarySystemBackground))
                #elseif os(macOS)
                .background(Color(NSColor.windowBackgroundColor))
                #endif
                .clipShape(RoundedRectangle(cornerRadius: 12))

            Spacer()
        }
        .padding()
    }
}
