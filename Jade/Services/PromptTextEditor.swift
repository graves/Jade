#if os(macOS)
import SwiftUI
import AppKit

struct PromptTextEditor: NSViewRepresentable {
    @Binding var text: String
    var onSubmit: () -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text, onSubmit: onSubmit)
    }

    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSScrollView()
        let textView = NSTextView()

        textView.delegate = context.coordinator
        textView.isRichText = false
        textView.font = .systemFont(ofSize: 14)
        textView.backgroundColor = .clear
        textView.isVerticallyResizable = true
        textView.textContainerInset = NSSize(width: 8, height: 6)
        textView.textContainer?.widthTracksTextView = true

        scrollView.borderType = .noBorder
        scrollView.hasVerticalScroller = true
        scrollView.documentView = textView

        context.coordinator.textView = textView
        return scrollView
    }

    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        guard let textView = context.coordinator.textView else { return }
        if textView.string != text {
            textView.string = text
        }
        context.coordinator.onSubmit = onSubmit
    }

    class Coordinator: NSObject, NSTextViewDelegate {
        var binding: Binding<String>
        var onSubmit: () -> Void
        weak var textView: NSTextView?

        init(text: Binding<String>, onSubmit: @escaping () -> Void) {
            self.binding = text
            self.onSubmit = onSubmit
        }

        func textDidChange(_ notification: Notification) {
            if let textView = notification.object as? NSTextView {
                binding.wrappedValue = textView.string
            }
        }

        func textView(_ textView: NSTextView, doCommandBy selector: Selector) -> Bool {
            if selector == #selector(NSResponder.insertNewline(_:)) {
                if NSEvent.modifierFlags.contains(.shift) {
                    textView.insertNewline(nil)
                } else {
                    onSubmit()
                }
                return true
            }
            return false
        }
    }
}
#endif
