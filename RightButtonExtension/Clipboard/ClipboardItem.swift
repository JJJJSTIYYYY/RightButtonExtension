//
//  ClipboardItem.swift
//  RightButtonExtension
//
//  Created by Justiy on 2026/1/6.
//

import Foundation

struct ClipboardItem: Identifiable, Equatable {
    let id = UUID()
    let content: String
    let date: Date
    let sourceApp: String?
    let binaryData: String?
}











                    