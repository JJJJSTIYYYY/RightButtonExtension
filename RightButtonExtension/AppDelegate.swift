//
//  AppDelegate.swift
//  RightButtonExtension
//
//  Created by Justiy on 2026/1/5.
//

import AppKit
import ServiceManagement

class AppDelegate: NSObject, NSApplicationDelegate {

    // MARK: - Constants

    /// UserDefaults key to record whether user has made a decision
    private static let launchAtLoginPromptedKey = "LaunchAtLoginPrompted"

    // MARK: - App Lifecycle

    func applicationDidFinishLaunching(_ notification: Notification) {
        StatusBarController.shared.setup()
        ClipboardMonitor.shared.start()
        ShiftDoubleTapMonitor.shared.start()

        // Only prompt if user has never made a decision
        if !UserDefaults.standard.bool(forKey: Self.launchAtLoginPromptedKey) {
            promptLaunchAtLoginIfNeeded()
        }
    }

    func application(
        _ application: NSApplication,
        open urls: [URL]
    ) {
        guard let url = urls.first else { return }
        handleURL(url)
    }

    // MARK: - Launch at Login

    private func promptLaunchAtLoginIfNeeded() {
        // If already enabled, mark as decided and return
        if SMAppService.mainApp.status == .enabled {
            UserDefaults.standard.set(true, forKey: Self.launchAtLoginPromptedKey)
            return
        }

        let alert = NSAlert()
        alert.messageText = "是否在开机时自动启用右键扩展？"
        alert.informativeText = """
        启用后，系统启动时会自动运行本程序，
        以确保 Finder 右键扩展始终可用。
        """
        alert.addButton(withTitle: "启用")
        alert.addButton(withTitle: "暂不")

        let response = alert.runModal()

        // Mark as prompted regardless of choice
        UserDefaults.standard.set(true, forKey: Self.launchAtLoginPromptedKey)

        if response == .alertFirstButtonReturn {
            enableLaunchAtLogin()
        }
    }

    private func enableLaunchAtLogin() {
        do {
            try SMAppService.mainApp.register()
        } catch {
            // Failure here should not block app startup
            NSLog("Failed to enable launch at login: \(error)")
        }
    }

    // MARK: - URL Handling

    private func handleURL(_ url: URL) {
        guard url.scheme == "rightbuttonextension" else { return }

        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        guard let dir = components?.queryItems?
            .first(where: { $0.name == "dir" })?.value else { return }

        let directoryURL = URL(fileURLWithPath: dir)

        switch url.host {
        case "newTextfile":
            FileCreator.createFileInteractively(
                in: directoryURL,
                mode: .text
            )

        case "newBinaryfile":
            FileCreator.createFileInteractively(
                in: directoryURL,
                mode: .binary
            )

        default:
            break
        }
    }
}
