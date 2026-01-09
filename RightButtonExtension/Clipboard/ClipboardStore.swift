//
//  ClipboardStore.swift
//  RightButtonExtension
//
//  Created by Justiy on 2026/1/6.
//

import Foundation

final class ClipboardStore {

    static let shared = ClipboardStore()
    private init() {}

    private(set) var items: [ClipboardItem] = []

    let maxCount = 100

    func insert(_ item: ClipboardItem) {
        // De-duplicate
        if items.first?.content == item.content {
            return
        }

        items.insert(item, at: 0)

        if items.count > maxCount {
            items.removeLast()
        }
    }

    func remove(_ item: ClipboardItem) {
        items.removeAll { $0.id == item.id }
    }
}
