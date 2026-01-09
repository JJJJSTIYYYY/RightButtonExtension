//
//  RightButtonExtensionApp.swift
//  RightButtonExtension
//
//  Created by Justiy on 2026/1/5.
//

import SwiftUI

@main
struct RightButtonExtensionApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self)
    var appDelegate
    
    var body: some Scene {
        Settings {
            EmptyView() // 无 UI App
        }
    }
}
