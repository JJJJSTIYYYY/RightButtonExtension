//
//  FileCreator.swift
//  RightButtonExtension
//
//  Created by Justiy on 2026/1/5.
//

import AppKit

enum CreateMode {
    case text
    case binary
}

enum FileCreator {

    static func createFileInteractively(
        in directory: URL,
        mode: CreateMode
    ) {
        PermissionChecker.checkAndGuideIfNeeded(in: directory)

        let alert = NSAlert()
        alert.messageText = "新建文件："
        alert.informativeText = "请输入文件名，文件将在目录 \(directory.path) 下创建."
        alert.addButton(withTitle: "创建")
        alert.addButton(withTitle: "取消")

        let input = NSTextField(frame: NSRect(x: 0, y: 0, width: 260, height: 24))
        input.placeholderString = mode == .text ? "example.txt" : "example.docx"
        alert.accessoryView = input

        guard alert.runModal() == .alertFirstButtonReturn else { return }

        let raw = input.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !raw.isEmpty else { return }

        switch mode {
        case .text:
            createTextFile(named: raw, in: directory)

        case .binary:
            createBinaryFile(named: raw, in: directory)
        }
    }
    
    private static func showErrorAlert(title: String, message: String) {
        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.alertStyle = .critical
            alert.messageText = title
            alert.informativeText = message
            alert.addButton(withTitle: "确定")
            alert.runModal()
        }
    }


    private static func createTextFile(named name: String, in dir: URL) {
        let fm = FileManager.default

        // ---------- Recover security-scoped access (use parent as security root) ----------
        var securityRootURL: URL?

        if let bookmarks = UserDefaults.standard.dictionary(forKey: "SavedDirectoryBookmarks") as? [String: Data] {

            // Find the nearest parent directory bookmark (longest path first)
            let sortedKeys = bookmarks.keys.sorted { $0.count > $1.count }

            for path in sortedKeys {
                if dir.path == path || dir.path.hasPrefix(path + "/") {
                    var isStale = false
                    if let url = try? URL(
                        resolvingBookmarkData: bookmarks[path]!,
                        options: .withSecurityScope,
                        relativeTo: nil,
                        bookmarkDataIsStale: &isStale
                    ) {
                        securityRootURL = url
                        break
                    }
                }
            }
        }

        // Start security-scoped access using the parent directory
        guard let securityRoot = securityRootURL,
              securityRoot.startAccessingSecurityScopedResource() else {
            showErrorAlert(
                title: "没有权限",
                message: "无法访问选定目录的安全范围：\(dir.path)"
            )
            return
        }
        defer { securityRoot.stopAccessingSecurityScopedResource() }

        // ---------- Validate file name ----------
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            showErrorAlert(
                title: "新建文件失败",
                message: "文件名不能为空。"
            )
            return
        }

        let base = (trimmed as NSString).deletingPathExtension
        let ext = (trimmed as NSString).pathExtension.isEmpty
            ? "txt"
            : (trimmed as NSString).pathExtension

        guard !base.isEmpty else {
            showErrorAlert(
                title: "新建文件失败",
                message: "文件名不合法。"
            )
            return
        }

        // ---------- Check target directory writable (must use dir, not security root) ----------
        guard fm.isWritableFile(atPath: dir.path) else {
            showErrorAlert(
                title: "没有权限",
                message: """
                无法在该目录创建文件：
                \(dir.path)

                请授予当前目录访问权限或选择其他目录。
                """
            )
            return
        }

        // ---------- Generate non-conflicting filename (use target dir) ----------
        var idx = 0
        var filePath: String

        repeat {
            let fileName = idx == 0 ? "\(base).\(ext)" : "\(base) \(idx).\(ext)"
            filePath = dir.appendingPathComponent(fileName).path // critical: use dir
            idx += 1
        } while fm.fileExists(atPath: filePath)

        // ---------- Actually create the file ----------
        let created = fm.createFile(atPath: filePath, contents: Data(), attributes: nil)
        guard created else {
            showErrorAlert(
                title: "新建文件失败",
                message: "无法创建文件：\(filePath)"
            )
            return
        }

        // ---------- Reveal in Finder ----------
        NSWorkspace.shared.activateFileViewerSelecting([URL(fileURLWithPath: filePath)])
    }
    
    private static func createBinaryFile(named name: String, in dir: URL) {
        let fm = FileManager.default

        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            showErrorAlert(title: "新建文件失败", message: "文件名不能为空。")
            return
        }

        let ext = (trimmed as NSString).pathExtension.lowercased()
        guard !ext.isEmpty else {
            showErrorAlert(
                title: "新建文件失败",
                message: "二进制文件必须包含扩展名。"
            )
            return
        }

        // ---------- Locate binary template (scan BinaryTemplates directory) ----------
        guard
            let templatesDir = Bundle.main.resourceURL?
                .appendingPathComponent("BinaryTemplates", isDirectory: true),
            let files = try? fm.contentsOfDirectory(
                at: templatesDir,
                includingPropertiesForKeys: nil,
                options: [.skipsHiddenFiles]
            ),
            let templateURL = files.first(where: {
                $0.pathExtension.lowercased() == ext
            })
        else {

            let supported = supportedExtensions()
            let hint = supported.isEmpty
                ? "模版库中未找到任何模板文件。"
                : "支持的类型：." + supported.joined(separator: " / .")

            showErrorAlert(
                title: "不支持的文件类型",
                message: """
                暂不支持 .\(ext) 文件。

                \(hint)
                """
            )
            return
        }

        // ---------- Resolve security-scoped access ----------
        var securityRootURL: URL?

        if let bookmarks = UserDefaults.standard.dictionary(forKey: "SavedDirectoryBookmarks") as? [String: Data] {
            let sortedKeys = bookmarks.keys.sorted { $0.count > $1.count }
            for path in sortedKeys {
                if dir.path == path || dir.path.hasPrefix(path + "/") {
                    var isStale = false
                    if let url = try? URL(
                        resolvingBookmarkData: bookmarks[path]!,
                        options: .withSecurityScope,
                        relativeTo: nil,
                        bookmarkDataIsStale: &isStale
                    ) {
                        securityRootURL = url
                        break
                    }
                }
            }
        }

        guard let securityRoot = securityRootURL,
              securityRoot.startAccessingSecurityScopedResource() else {
            showErrorAlert(title: "没有权限", message: dir.path)
            return
        }
        defer { securityRoot.stopAccessingSecurityScopedResource() }

        // ---------- Generate non-conflicting file path ----------
        let base = (trimmed as NSString).deletingPathExtension
        var idx = 0
        var targetURL: URL

        repeat {
            let fileName = idx == 0
                ? "\(base).\(ext)"
                : "\(base) \(idx).\(ext)"
            targetURL = dir.appendingPathComponent(fileName)
            idx += 1
        } while fm.fileExists(atPath: targetURL.path)

        // ---------- Copy template ----------
        do {
            try fm.copyItem(at: templateURL, to: targetURL)
        } catch {
            showErrorAlert(
                title: "新建文件失败",
                message: error.localizedDescription
            )
            return
        }

        // ---------- Reveal in Finder ----------
        NSWorkspace.shared.activateFileViewerSelecting([targetURL])
    }

    // Return supported file extensions from BinaryTemplates directory
    private static func supportedExtensions() -> [String] {
        guard
            let templatesURL = Bundle.main.url(forResource: "BinaryTemplates", withExtension: nil),
            let files = try? FileManager.default.contentsOfDirectory(
                at: templatesURL,
                includingPropertiesForKeys: nil,
                options: [.skipsHiddenFiles]
            )
        else {
            return []
        }

        return files
            .map { $0.pathExtension.lowercased() }
            .filter { !$0.isEmpty }
            .sorted()
    }

}

