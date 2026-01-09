//
//  ClipboardMonitor.swift
//  RightButtonExtension
//
//  Created by Justiy on 2026/1/6.
//

import AppKit

final class ClipboardMonitor {

    static let shared = ClipboardMonitor()

    private let pasteboard = NSPasteboard.general
    private var lastChangeCount = NSPasteboard.general.changeCount

    private init() {}

    func start() {
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            self.check()
        }
    }

    private func check() {
        guard pasteboard.changeCount != lastChangeCount else { return }
        lastChangeCount = pasteboard.changeCount

        guard let text = pasteboard.string(forType: .string),
              !text.isEmpty else { return }

        let appName = NSWorkspace.shared.frontmostApplication?.localizedName

        ClipboardStore.shared.insert(
            ClipboardItem(
                content: text,
                date: .now,
                sourceApp: appName,
                binaryData: nil
            )
        )
    }
}
