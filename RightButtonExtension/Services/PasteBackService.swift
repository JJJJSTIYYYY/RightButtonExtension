import AppKit

enum PasteBackService {

    /// 统一接口：点击某条剪贴板记录触发回贴
    static func paste(item: ClipboardItem) {
        // 1. 写入系统剪贴板
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(item.content, forType: .string)

        // 2. 移动记录到顶部
        ClipboardStore.shared.remove(item)
        ClipboardStore.shared.insert(item)

        // 3. 隐藏面板并模拟回贴
        pasteAfterPanelDismiss()
    }

    private static func pasteAfterPanelDismiss() {
        // Close clipboard panel
        ClipboardPanelController.shared.toggle()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {

            PasteBackContext.activateSourceApp()

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                guard StatusBarController.isPasteBackEnabled else {
                    PasteBackContext.clear()
                    return
                }
                simulatePaste()
                PasteBackContext.clear()
            }
        }
    }

    private static func simulatePaste() {
        guard let source = CGEventSource(stateID: .hidSystemState) else { return }

        // Command key down
        guard let cmdDown = CGEvent(keyboardEventSource: source, virtualKey: 0x37, keyDown: true) else { return }
        cmdDown.flags = .maskCommand

        // V key down
        guard let vDown = CGEvent(keyboardEventSource: source, virtualKey: 0x09, keyDown: true) else { return }
        vDown.flags = .maskCommand

        // V key up
        guard let vUp = CGEvent(keyboardEventSource: source, virtualKey: 0x09, keyDown: false) else { return }

        // Command key up
        guard let cmdUp = CGEvent(keyboardEventSource: source, virtualKey: 0x37, keyDown: false) else { return }

        cmdDown.post(tap: .cghidEventTap)
        vDown.post(tap: .cghidEventTap)
        vUp.post(tap: .cghidEventTap)
        cmdUp.post(tap: .cghidEventTap)
    }
}
