import AppKit

enum PasteBackContext {

    // The app that was active before clipboard panel showed
    private static var sourceApp: NSRunningApplication?

    /// Record current frontmost application
    static func captureSourceAppIfNeeded() {
//        guard sourceApp == nil else { return }
        clear()

        guard
            let app = NSWorkspace.shared.frontmostApplication,
            app.bundleIdentifier != Bundle.main.bundleIdentifier
        else {
            return
        }

        sourceApp = app
    }


    /// Activate previously recorded application
    static func activateSourceApp() {
        guard let app = sourceApp else { return }

        // Activate application (Sonoma-safe)
        app.activate(options: [.activateAllWindows])

        // Bring windows to front explicitly
        NSRunningApplication.current.activate(options: [])
        
        clear()

        // Note:
        // macOS 14 ignores activateIgnoringOtherApps completely,
        // so we rely on activateAllWindows + focus timing instead.
    }

    /// Clear after paste if you want (optional)
    static func clear() {
        sourceApp = nil
    }
}
