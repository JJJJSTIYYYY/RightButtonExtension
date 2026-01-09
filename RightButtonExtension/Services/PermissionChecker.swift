//
//  PermissionChecker.swift
//  RightButtonExtension
//
//  Created by Justiy on 2026/1/5.
//

import AppKit
import Cocoa

enum PermissionChecker {

    static func checkAndGuideIfNeeded(in directory: URL) {
        if hasFullDiskAccess(in: directory) {
            return
        }

        let alert = NSAlert()
        alert.messageText = "需要磁盘访问权限"
        alert.informativeText = """
    需要访问你的文件系统以在 Finder 中创建文件。
    """
        alert.addButton(withTitle: "前往选择")
        alert.addButton(withTitle: "退出")

        if alert.runModal() == .alertFirstButtonReturn {
            openDiskAccessPanel(in: directory)
        }

        NSApp.terminate(nil)
    }

    private static func hasFullDiskAccess(in directory: URL) -> Bool {
        let fm = FileManager.default

        // ---------- 修改点: 从多 bookmark 中查找最近的父目录 ----------
        if let bookmarks = UserDefaults.standard.dictionary(forKey: "SavedDirectoryBookmarks") as? [String: Data] {

            // 优先匹配路径最长的（最近父目录）
            let sortedKeys = bookmarks.keys.sorted { $0.count > $1.count }

            for path in sortedKeys {
                if directory.path == path || directory.path.hasPrefix(path + "/") {
                    var isStale = false
                    if let url = try? URL(
                        resolvingBookmarkData: bookmarks[path]!,
                        options: .withSecurityScope,
                        relativeTo: nil,
                        bookmarkDataIsStale: &isStale
                    ), url.startAccessingSecurityScopedResource() {

                        defer { url.stopAccessingSecurityScopedResource() }

                        // 修改点: 在 security scope 内部再做真实读写判断
                        var isDirectory: ObjCBool = false
                        let exists = fm.fileExists(
                            atPath: directory.path,
                            isDirectory: &isDirectory
                        )

                        if exists && isDirectory.boolValue {
                            return fm.isReadableFile(atPath: directory.path)
                                && fm.isWritableFile(atPath: directory.path)
                        }

                        return false
                    }
                }
            }
        }

        return false
    }


    private static func openDiskAccessPanel(in directory: URL) {
        let panel = NSOpenPanel()
        panel.title = "请选择访问的文件夹"
        panel.message = "需要对此目录的读写权限"
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.directoryURL = directory

        let response = panel.runModal()
        guard response == .OK, let selectedURL = panel.url else { return }

        do {
            let bookmark = try selectedURL.bookmarkData(
                options: .withSecurityScope,
                includingResourceValuesForKeys: nil,
                relativeTo: nil
            )
            // ---------- 修改点: 将 bookmark 存储到以目录路径为 key 的字典中 ----------
            var bookmarks = UserDefaults.standard.dictionary(forKey: "SavedDirectoryBookmarks") as? [String: Data] ?? [:]
            bookmarks[selectedURL.path] = bookmark
            UserDefaults.standard.set(bookmarks, forKey: "SavedDirectoryBookmarks")
        } catch {
            let alert = NSAlert()
            alert.alertStyle = .critical
            alert.messageText = selectedURL.path
            alert.informativeText = error.localizedDescription
            alert.addButton(withTitle: "确定")
            alert.runModal()
        }
    }

}

