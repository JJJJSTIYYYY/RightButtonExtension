# Finder 右键扩展工具

**中文** | [English](#english-version)

---

## 功能特性

### 1. 右键菜单增强
在访达（Finder）右键菜单中新增以下创建选项：

- **新建文本文件** (.txt/.md/.drawio/.html/...)

- **新建二进制文件** (.docx/.pptx/.xlsx/.pdf)

### 2. 快捷操作
- **双击 Shift 键**：快速打开剪贴板历史记录面板

---

## 演示截图
![右键菜单演示](https://github.com/JJJJSTIYYYY/DataRepository/blob/b36af7c6d281287bb2f274a5a5683d0dfc178766/Pic/RightButtonFinderExtension/menu%20extension.png?raw=true)
![新建文件演示](https://github.com/JJJJSTIYYYY/DataRepository/blob/b36af7c6d281287bb2f274a5a5683d0dfc178766/Pic/RightButtonFinderExtension/filename%20input.png?raw=true)
![剪贴板演示](https://github.com/JJJJSTIYYYY/DataRepository/blob/b36af7c6d281287bb2f274a5a5683d0dfc178766/Pic/RightButtonFinderExtension/clipboard%20record.png?raw=true)

---

## 安装说明
1. 命令行执行 `git clone https://github.com/JJJJSTIYYYY/RightButtonExtension.git`
2. 使用 **xcode** 打开 **RightButtonExtension.xcodeproj** 工程文件
3. xcode菜单 > Product > Archive > Distribute App > Custom > Copy App > Export
4. 首次运行时需要在系统设置中授予辅助功能权限与文件夹访问权限
5. 由于没有Apple开发者账号会员，使用swift原发开发的App每隔7天需要重新导出，否则会出现包损坏或者未认证发布者提示

## 使用说明
### 创建新文件
1. 新建文本未指定文件后缀默认为txt
2. 新建二进制文件必须指定后缀
3. 选择需要创建的文件类型
4. 首次运行后需执行命令 `killall Finder`

### 剪贴板历史
- 在任何界面双击 **Shift 键**（左右 Shift 均可）
- 从历史记录中选择内容即可粘贴（可在菜单栏图标中取消勾选 `启用回贴` 来关闭自动粘贴）
- 最多记录100条最近复制内容

---

## 更新日志
### v1.0.0 (2026.01.10)
- 初始版本发布
- 支持基础文件创建功能
- 支持剪贴板历史记录

---

<a id="english-version"></a>
# Finder Context Menu Extension

**English** | [中文](#)

---

## Features

### 1. Enhanced Context Menu
Adds the following new creation options to Finder's right-click menu:

- **New Text File** (.txt/.md/.drawio/.html/...)

- **New Binary File** (.docx/.pptx/.xlsx/.pdf)

### 2. Quick Actions
- **Double-tap Shift Key**: Quickly open clipboard history panel

---

## Screenshots
![Context Menu Demo](https://github.com/JJJJSTIYYYY/DataRepository/blob/b36af7c6d281287bb2f274a5a5683d0dfc178766/Pic/RightButtonFinderExtension/menu%20extension.png?raw=true)
![New File Creation Demo](https://github.com/JJJJSTIYYYY/DataRepository/blob/b36af7c6d281287bb2f274a5a5683d0dfc178766/Pic/RightButtonFinderExtension/filename%20input.png?raw=true)
![Clipboard Demo](https://github.com/JJJJSTIYYYY/DataRepository/blob/b36af7c6d281287bb2f274a5a5683d0dfc178766/Pic/RightButtonFinderExtension/clipboard%20record.png?raw=true)

---

## Installation
1. Execute in terminal: `git clone https://github.com/JJJJSTIYYYY/RightButtonExtension.git`
2. Open **RightButtonExtension.xcodeproj** with **Xcode**
3. Xcode menu > Product > Archive > Distribute App > Custom > Copy App > Export
4. On first launch, grant Accessibility and Full Disk Access permissions in System Settings
5. Note: Without an Apple Developer membership, this Swift-based app needs to be re-exported every 7 days to avoid "damaged package" or "unverified developer" warnings

## Usage
### Creating New Files
1. New text files default to .txt extension if not specified
2. Binary files require explicit extension specification
3. Select desired file type to create
4. After first run, execute `killall Finder` in terminal

### Clipboard History
- Double-tap **Shift key** (left or right) in any application
- Select content from history to paste automatically (disable "Auto Paste" in menu bar icon if desired)
- Maximum of 100 most recent clipboard items stored

---

## Changelog
### v1.0.0 (2026.01.10)
- Initial release
- Basic file creation functionality
- Clipboard history management

---

## System Requirements
- macOS 13.0 or later
- Xcode 14.0 or later (for building)

## Troubleshooting
### Menu Items Not Appearing?
- Ensure the app is running in the background
- Check System Settings > Privacy & Security > Accessibility for proper permissions
- Try executing `killall Finder` in terminal

### Clipboard History Not Working?
- Verify the app is running (check menu bar icon)
- Ensure no other applications are using the Shift key shortcut

## Known Issues
- App requires re-export every 7 days without Apple Developer membership
- Some file type icons may not appear immediately after creation

## Support
For issues or feature requests, please:
1. Check existing issues on GitHub
2. Submit a new issue with detailed description

---

**License**: MIT License  
**Version**: 1.0.0  
**Author**: JJJJSTIYYYY  
**Repository**: [RightButtonExtension](https://github.com/JJJJSTIYYYY/RightButtonExtension)
