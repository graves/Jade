//
//  AppExtensions.swift
//  Jade
//
//  Created by Thomas Gentry on 5/21/25.
//
#if os(macOS)
import AppKit

extension Notification.Name {
    static let keyDownEvent = Notification.Name("KeyDownEvent")
}

extension NSEvent {
    static func startMonitoringKeyDown() {
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            NotificationCenter.default.post(
                name: .keyDownEvent,
                object: nil,
                userInfo: ["event": event]
            )
            return event
        }
    }
}
#endif

