import SwiftUI
import AppKit
internal import Combine

final class ClipboardPanelController {

    static let shared = ClipboardPanelController()

    private var window: NSWindow?
    private var isHiding = false

    // Global mouse monitor for outside click detection
    private var mouseMonitor: Any?

    private init() {}

    // MARK: - Public

    func toggle() {
        if let window, window.isVisible {
            hideAnimated()
            return
        }

        // Do not show panel if there is no clipboard record
        guard !ClipboardStore.shared.items.isEmpty else {
            return
        }

        showAnimated()
    }

    // MARK: - Show

    private func showAnimated() {
        if window == nil {
            window = makeWindow()
        }

        guard let window else { return }

        isHiding = false

        // Activate agent app without showing Dock icon
        NSApp.activate()

        // Resize window before showing
        resizeWindow(forItemCount: ClipboardStore.shared.items.count)

        // Position near mouse
        let finalFrame = calculateWindowFrame(atMouseLocationFor: window)
        var startFrame = finalFrame
        startFrame.origin.y -= 20

        window.alphaValue = 0
        window.setFrame(startFrame, display: false)
        window.makeKeyAndOrderFront(nil)

        NSAnimationContext.runAnimationGroup { ctx in
            ctx.duration = 0.22
            ctx.timingFunction = CAMediaTimingFunction(name: .easeOut)
            window.animator().alphaValue = 1
            window.animator().setFrame(finalFrame, display: true)
        }

        installOutsideClickMonitor()
    }

    // MARK: - Hide

    private func hideAnimated() {
        guard let window, window.isVisible, !isHiding else { return }
        isHiding = true

        removeOutsideClickMonitor()

        var endFrame = window.frame
        endFrame.origin.y -= 20

        NSAnimationContext.runAnimationGroup({ ctx in
            ctx.duration = 0.18
            ctx.timingFunction = CAMediaTimingFunction(name: .easeIn)
            window.animator().alphaValue = 0
            window.animator().setFrame(endFrame, display: true)
        }, completionHandler: {
            window.orderOut(nil)
            window.alphaValue = 1
            self.isHiding = false
        })
    }

    // MARK: - Outside Click Detection

    private func installOutsideClickMonitor() {
        removeOutsideClickMonitor()

        mouseMonitor = NSEvent.addGlobalMonitorForEvents(
            matching: [.leftMouseDown, .rightMouseDown]
        ) { [weak self] event in
            guard
                let self,
                let window = self.window
            else { return }

            // Convert event location to screen coordinates
            let clickLocation = NSEvent.mouseLocation

            // Hide panel when clicking outside window
            if !window.frame.contains(clickLocation) {
                DispatchQueue.main.async {
                    self.hideAnimated()
                }
            }
        }
    }

    private func removeOutsideClickMonitor() {
        if let monitor = mouseMonitor {
            NSEvent.removeMonitor(monitor)
            mouseMonitor = nil
        }
    }

    // MARK: - Window

    private func makeWindow() -> NSWindow {
        let hostingView = NSHostingView(
            rootView: ClipboardPanelView { [weak self] count in
                self?.resizeWindow(forItemCount: count)
            }
        )

        let window = NSWindow(
            contentRect: NSRect(
                x: 0,
                y: 0,
                width: ClipboardUIConfig.windowWidth,
                height: ClipboardUIConfig.minWindowHeight
            ),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )

        window.level = .floating
        window.isReleasedWhenClosed = false
        window.isOpaque = false
        window.backgroundColor = .clear
        window.contentView = hostingView

        return window
    }

    // MARK: - Resize

    private func resizeWindow(forItemCount count: Int) {
        guard let window else { return }

        let contentHeight =
            CGFloat(count) * ClipboardUIConfig.rowHeight
            + CGFloat(max(0, count - 1)) * ClipboardUIConfig.rowSpacing
            + ClipboardUIConfig.verticalPadding

        let targetHeight = min(
            max(contentHeight, ClipboardUIConfig.minWindowHeight),
            ClipboardUIConfig.maxWindowHeight
        )

        var frame = window.frame
        let delta = targetHeight - frame.height
        guard abs(delta) > 1 else { return }

        frame.origin.y -= delta
        frame.size.height = targetHeight

        NSAnimationContext.runAnimationGroup { ctx in
            ctx.duration = 0.15
            ctx.timingFunction = CAMediaTimingFunction(name: .easeOut)
            window.animator().setFrame(frame, display: true)
        }
    }

    // MARK: - Mouse positioning

    private func calculateWindowFrame(atMouseLocationFor window: NSWindow) -> NSRect {
        let mouseLocation = NSEvent.mouseLocation
        let windowSize = window.frame.size

        let screen = NSScreen.screens.first {
            $0.frame.contains(mouseLocation)
        } ?? NSScreen.main

        let screenFrame = screen?.visibleFrame ?? .zero

        var originX = mouseLocation.x
        var originY = mouseLocation.y - windowSize.height - 12

        if originX + windowSize.width > screenFrame.maxX {
            originX = screenFrame.maxX - windowSize.width
        }
        if originX < screenFrame.minX {
            originX = screenFrame.minX
        }
        if originY < screenFrame.minY {
            originY = mouseLocation.y + 12
        }
        if originY + windowSize.height > screenFrame.maxY {
            originY = screenFrame.maxY - windowSize.height
        }

        return NSRect(
            x: originX,
            y: originY,
            width: windowSize.width,
            height: windowSize.height
        )
    }
}
