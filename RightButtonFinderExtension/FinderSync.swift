//
//  FinderSync.swift
//  RBExt_finder
//
//  Created by Justiy on 2026/1/5.
//

import Cocoa
import FinderSync

class FinderSync: FIFinderSync {

    override init() {
        super.init()
        FIFinderSyncController.default().directoryURLs = [
            URL(fileURLWithPath: "/")
        ]
    }

    override func menu(for menuKind: FIMenuKind) -> NSMenu? {
        let menu = NSMenu(title: "")
        let item1 = NSMenuItem(
            title: "新建文本文件",
            action: #selector(onNewTextFile),
            keyEquivalent: "j",
        )
        item1.target = self
        item1.image = NSImage(systemSymbolName: "doc.text", accessibilityDescription: nil)
        item1.keyEquivalentModifierMask = [.command, .option]
        menu.addItem(item1)

        let item2 = NSMenuItem(
            title: "新建二进制文件",
            action: #selector(onNewBinaryFile),
            keyEquivalent: "k",
        )
        item2.target = self
        item2.image = NSImage(systemSymbolName: "doc.richtext", accessibilityDescription: nil)
        item2.keyEquivalentModifierMask = [.command, .option]
        menu.addItem(item2)


        return menu
    }
    
    @objc private func onNewTextFile() {
        let urls = FIFinderSyncController.default().selectedItemURLs() ?? []
        guard let first = urls.first else { return }

        let dir = resolveDirectory(from: first)
        openHostApp_text(directory: dir)
    }
    
    @objc private func onNewBinaryFile() {
        let urls = FIFinderSyncController.default().selectedItemURLs() ?? []
        guard let first = urls.first else { return }

        let dir = resolveDirectory(from: first)
        openHostApp_binary(directory: dir)
    }

    private func resolveDirectory(from url: URL) -> URL {
        var isDir: ObjCBool = false
        FileManager.default.fileExists(atPath: url.path, isDirectory: &isDir)
        return isDir.boolValue ? url : url.deletingLastPathComponent()
    }
    
    private func openHostApp_text(directory: URL) {
        let encoded = directory.path.addingPercentEncoding(
            withAllowedCharacters: .urlQueryAllowed
        ) ?? ""

        let urlString = "rightbuttonextension://newTextfile?dir=\(encoded)"
        guard let url = URL(string: urlString) else { return }

        NSWorkspace.shared.open(url)
    }
    
    private func openHostApp_binary(directory: URL) {
        let encoded = directory.path.addingPercentEncoding(
            withAllowedCharacters: .urlQueryAllowed
        ) ?? ""

        let urlString = "rightbuttonextension://newBinaryfile?dir=\(encoded)"
        guard let url = URL(string: urlString) else { return }

        NSWorkspace.shared.open(url)
    }
}
