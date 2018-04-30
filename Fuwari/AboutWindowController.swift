//
//  AboutWindowController.swift
//  Fuwari
//
//  Created by Kengo Yokoyama on 2016/12/28.
//  Copyright © 2016年 AppKnop. All rights reserved.
//

import Cocoa

class AboutWindowController: NSWindowController {

    static let shared = AboutWindowController(windowNibName: NSNib.Name(rawValue: "AboutWindowController"))
    
    @IBOutlet private weak var versionTextField: NSTextField! {
        didSet {
            if let versionString = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String {
                versionTextField.stringValue = "v\(versionString)"
            }
        }
    }
    
    override func showWindow(_ sender: Any?) {
        super.showWindow(sender)
        window?.makeKeyAndOrderFront(self)
    }
}

extension AboutWindowController: NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        if let window = window, !window.makeFirstResponder(window) {
            window.endEditing(for: nil)
        }
        NSApp.deactivate()
    }
}
