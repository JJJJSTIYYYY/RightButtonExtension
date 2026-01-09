//
//  ShiftDoubleTapMonitor.swift
//  RightButtonExtension
//
//  Created by Justiy on 2026/1/6.
//

import SwiftUI
import AppKit
import Cocoa

final class ShiftDoubleTapMonitor {

    static let shared = ShiftDoubleTapMonitor()

    private var lastTapTime: CFAbsoluteTime = 0
    private let interval: CFAbsoluteTime = 0.3

    private var eventTap: CFMachPort?

    // Track shift pressed state to avoid repeat trigger
    private var isShiftDown = false

    private init() {}

    func start() {
        let mask = CGEventMask(1 << CGEventType.flagsChanged.rawValue)

        AlertShow.showAlert(
            title: "ShiftDoubleTapMonitor",
            message: "start() called"
        )

        eventTap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: mask,
            callback: { _, type, event, _ in
                guard type == .flagsChanged else {
                    return Unmanaged.passUnretained(event)
                }

                ShiftDoubleTapMonitor.shared.handle(event)
                return Unmanaged.passUnretained(event)
            },
            userInfo: nil
        )

        guard let tap = eventTap else {
            AlertShow.showAlert(
                title: "ShiftDoubleTapMonitor ❌",
                message: "Failed to create event tap.\nCheck Input Monitoring permission."
            )
            return
        }

        let runLoopSource = CFMachPortCreateRunLoopSource(
            kCFAllocatorDefault,
            tap,
            0
        )

        CFRunLoopAddSource(
            CFRunLoopGetMain(),
            runLoopSource,
            .commonModes
        )

        CGEvent.tapEnable(tap: tap, enable: true)

        AlertShow.showAlert(
            title: "ShiftDoubleTapMonitor",
            message: "Event tap enabled"
        )
    }

    private func handle(_ event: CGEvent) {
        let flags = event.flags
        let keyCode = event.getIntegerValueField(.keyboardEventKeycode)

        // Only care about Left Shift (56) or Right Shift (60)
        guard keyCode == 56 || keyCode == 60 else { return }

        if flags.contains(.maskShift) {
            // Shift pressed
            if isShiftDown {
                return
            }
            isShiftDown = true
            
            PasteBackContext.captureSourceAppIfNeeded()

            let now = CFAbsoluteTimeGetCurrent()
            let delta = now - lastTapTime

            AlertShow.showAlert(
                title: "Shift pressed",
                message: String(format: "delta = %.3f", delta)
            )

            if delta < interval {
                AlertShow.showAlert(
                    title: "Shift Double Tap ✅",
                    message: "Trigger clipboard panel"
                )
                invokeClipboardRecord()
            }

            lastTapTime = now

        } else {
            // Shift released
            isShiftDown = false
        }
    }
    
    private func invokeClipboardRecord() {
        // Use the existing ClipboardPanelController which is already in this target
        ClipboardPanelController.shared.toggle()
        
        AlertShow.showAlert(
            title: "invokeClipboardRecord",
            message: "invoked."
        )
    }
}
