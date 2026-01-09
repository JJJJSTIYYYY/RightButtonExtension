import AppKit

final class StatusBarController {

    static let shared = StatusBarController()

    private var statusItem: NSStatusItem?
    private var toggleItem: NSMenuItem?

    // UserDefaults key
    private let pasteEnabledKey = "PasteBackEnabled"

    private init() {}

    // MARK: - Public

    func setup() {
        let item = NSStatusBar.system.statusItem(
            withLength: NSStatusItem.squareLength
        )

        item.button?.image = NSImage(
            systemSymbolName: "doc.on.clipboard",
            accessibilityDescription: "Clipboard Panel"
        )

        let menu = NSMenu()

        // Toggle Paste Back
        let toggle = NSMenuItem(
            title: "启用回贴",
            action: #selector(togglePasteBack),
            keyEquivalent: ""
        )
        toggle.target = self
        toggle.state = isPasteBackEnabled ? .on : .off
        menu.addItem(toggle)
        self.toggleItem = toggle

        menu.addItem(.separator())

        // Quit
        let quitItem = NSMenuItem(
            title: "退出",
            action: #selector(quit),
            keyEquivalent: "q"
        )
        quitItem.target = self
        quitItem.keyEquivalentModifierMask = [.command]
        menu.addItem(quitItem)

        item.menu = menu
        self.statusItem = item
    }

    // MARK: - Paste Back State

    /// Global read access
    static var isPasteBackEnabled: Bool {
        UserDefaults.standard.bool(forKey: "PasteBackEnabled")
    }

    private var isPasteBackEnabled: Bool {
        UserDefaults.standard.object(forKey: pasteEnabledKey) as? Bool ?? true
    }

    private func setPasteBackEnabled(_ enabled: Bool) {
        UserDefaults.standard.set(enabled, forKey: pasteEnabledKey)
        toggleItem?.state = enabled ? .on : .off
    }

    @objc private func togglePasteBack() {
        let newValue = !isPasteBackEnabled
        setPasteBackEnabled(newValue)
    }

    // MARK: - Quit

    @objc private func quit() {
        NSApp.terminate(nil)
    }
}
