//
//  showAlert.swift
//  RightButtonExtension
//
//  Created by Justiy on 2026/1/6.
//

import AppKit

enum AlertShow {
    public static func showAlert(title: String, message: String) {
        
        let debug = false
        
        if (debug == false) {return}
        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.alertStyle = .critical
            alert.messageText = title
            alert.informativeText = message
            alert.addButton(withTitle: "确定")
            alert.runModal()
        }
    }
}
