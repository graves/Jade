import SwiftUI

struct PromptField: View {
    @Binding var prompt: String
    @State private var task: Task<Void, Never>?
    @FocusState private var isFocused: Bool

    let sendButtonAction: () async -> Void
    let mediaButtonAction: (() -> Void)?

    @State private var animatedColors: [Color] = [.blue, .purple, .blue]

    #if os(macOS)
    @State private var editorHeight: CGFloat = 60
    @State private var animate = false
    #endif

    var body: some View {
        VStack(spacing: 4) {
            #if os(macOS)
            HStack {
                Spacer()
                Rectangle()
                    .frame(width: 80, height: 6)
                    .foregroundColor(Color.gray.opacity(0.4))
                    .cornerRadius(3)
                    .padding(.vertical, 4)
                    .contentShape(Rectangle())
                    .onHover { _ in NSCursor.resizeUpDown.set() }
                    .gesture(
                        DragGesture(minimumDistance: 2)
                            .onChanged { value in
                                editorHeight = max(40, editorHeight - value.translation.height)
                            }
                    )
                Spacer()
            }
            #endif

            HStack(alignment: .bottom) {
                if let mediaButtonAction {
                    Button(action: mediaButtonAction) {
                        Image(systemName: "photo.badge.plus")
                            .padding(.bottom, 4)
                    }
                }

                #if os(macOS)
                ZStack {
                    if isRunning {
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(
                                AngularGradient(
                                    gradient: Gradient(colors: animatedColors),
                                    center: .center
                                ),
                                lineWidth: 2.5
                            )
                            .shadow(color: Color.purple.opacity(0.6), radius: 10)
                            .onAppear {
                                startColorCycle()
                            }
                    } else {
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    }

                    TextEditor(text: $prompt)
                        .focused($isFocused)
                        .font(.system(size: 14))
                        .padding(8)
                        .background(Color.clear)
                        .onReceive(NotificationCenter.default.publisher(for: .keyDownEvent)) { notif in
                            guard let event = notif.userInfo?["event"] as? NSEvent else { return }
                            if event.keyCode == 36 { // Return key
                                if event.modifierFlags.contains(.shift) {
                                    prompt.append("\n")
                                } else {
                                    let trimmed = prompt.trimmingCharacters(in: .whitespacesAndNewlines)
                                    prompt = trimmed
                                    task = Task {
                                        await sendButtonAction()
                                        removeTask()
                                    }
                                    prompt = ""
                                }
                            }
                        }
                }
                .frame(height: editorHeight)
                .background(Color(NSColor.textBackgroundColor))
                .cornerRadius(6)
                #else
                ZStack {
                    if isRunning {
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(
                                AngularGradient(
                                    gradient: Gradient(colors: animatedColors),
                                    center: .center
                                ),
                                lineWidth: 2.5
                            )
                            .shadow(color: Color.purple.opacity(0.6), radius: 10)
                            .onAppear {
                                startColorCycle()
                            }
                    } else {
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    }

                    TextEditor(text: $prompt)
                        .focused($isFocused)
                        .padding(8)
                        .font(.body)
                        .background(Color(UIColor.secondarySystemBackground))
                        .frame(minHeight: 20)
                }
                .frame(maxHeight: 100)
                #endif

                Button {
                    if isRunning {
                        task?.cancel()
                        removeTask()
                    } else {
                        task = Task {
                            await sendButtonAction()
                            removeTask()
                        }
                    }
                } label: {
                    #if os(macOS)
                    Label("Send", systemImage: isRunning ? "stop.circle.fill" : "paperplane.fill")
                        .labelStyle(.titleAndIcon)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.accentColor.opacity(0.1))
                        .cornerRadius(8)
                    #else
                    Image(systemName: isRunning ? "stop.circle.fill" : "paperplane.fill")
                        .font(.system(size: 20))
                    #endif
                }
                .padding(.bottom, 4)
            }
        }
    }

    private var isRunning: Bool {
        task != nil && !(task!.isCancelled)
    }

    private func removeTask() {
        task = nil
    }

    private func startColorCycle() {
        Timer.scheduledTimer(withTimeInterval: 0.8, repeats: true) { _ in
            guard isRunning else { return }
            withAnimation(.easeInOut(duration: 0.8)) {
                let first = animatedColors.removeFirst()
                animatedColors.append(first)
            }
        }
    }
}
