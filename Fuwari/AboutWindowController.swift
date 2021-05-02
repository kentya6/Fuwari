//
//  AboutWindowController.swift
//  Fuwari
//
//  Created by Kengo Yokoyama on 2016/12/28.
//  Copyright © 2016年 AppKnop. All rights reserved.
//

import Cocoa

class AboutWindowController: NSWindowController {

    static let shared = AboutWindowController(windowNibName: "AboutWindowController")
    
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
    
    @IBAction private func didTouchFuwariButton(_ sender: NSButton) {
        NSWorkspace.shared.open(URL(string: "https://github.com/sskmy1024y/Fuwari")!)
    }
    
    @IBAction private func didTouchTwitterButton(_ sender: NSButton) {
        NSWorkspace.shared.open(URL(string: "https://twitter.com/sskmy1024r")!)
    }
    
    @IBAction private func didTouchGitHubButton(_ sender: NSButton) {
        NSWorkspace.shared.open(URL(string: "https://github.com/sskmy1024y")!)
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
