//
//  PreferencesWindowController.swift
//  Fuwari
//
//  Created by Kengo Yokoyama on 2016/12/11.
//  Copyright © 2016年 AppKnop. All rights reserved.
//

import Cocoa

class PreferencesWindowController: NSWindowController {

    static let shared = PreferencesWindowController(windowNibName: "PreferencesWindowController")
    
    @IBOutlet private weak var toolBar: NSView!
    @IBOutlet private weak var generalImageView: NSImageView!
    @IBOutlet private weak var shortcutImageView: NSImageView!
    @IBOutlet private weak var generalTextField: NSTextField!
    @IBOutlet private weak var shortcutTextField: NSTextField!
    @IBOutlet private weak var generalButton: NSButton!
    @IBOutlet private weak var shortcutButton: NSButton!
    
    private let defaults = UserDefaults.standard
    private let viewController = [GeneralPreferenceViewController(nibName: "GeneralPreferenceViewController", bundle: nil),
                                      ShortcutsPreferenceViewController(nibName: "ShortcutsPreferenceViewController", bundle: nil)]
    
    override func windowDidLoad() {
        super.windowDidLoad()
        window?.collectionBehavior = .canJoinAllSpaces
        if #available(OSX 10.10, *) {
            window?.titlebarAppearsTransparent = true
        }
        toolBarItemTapped(generalButton)
        generalButton.sendAction(on: .leftMouseDown)
        shortcutButton.sendAction(on: .leftMouseDown)
    }
    
    override func showWindow(_ sender: Any?) {
        super.showWindow(sender)
        window?.makeKeyAndOrderFront(self)
    }
    
    @IBAction private func toolBarItemTapped(_ sender: NSButton) {
        selectedTab(sender.tag)
        switchView(sender.tag)
    }
}

extension PreferencesWindowController: NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        if let window = window, !window.makeFirstResponder(window) {
            window.endEditing(for: nil)
        }
        NSApp.deactivate()
    }
}

// MARK: - Layout
private extension PreferencesWindowController {
    private func resetImages() {
        generalImageView.image = NSImage(named: Constants.ImageName.generalOff)
        shortcutImageView.image = NSImage(named: Constants.ImageName.shortcutOff)
        
        generalTextField.textColor = .tabTitle
        shortcutTextField.textColor = .tabTitle
    }
    
    func selectedTab(_ index: Int) {
        resetImages()
        
        switch index {
        case 0:
            generalImageView.image = NSImage(named: Constants.ImageName.generalOn)
            generalTextField.textColor = .main
        case 1:
            shortcutImageView.image = NSImage(named: Constants.ImageName.shortcutOn)
            shortcutTextField.textColor = .main
        default: break
        }
    }
    
    func switchView(_ index: Int) {
        let newView = viewController[index].view
        // Remove current views without toolbar
        window?.contentView?.subviews.forEach { view in
            if view != toolBar {
                view.removeFromSuperview()
            }
        }
        // Resize view
        let frame = window!.frame
        var newFrame = window!.frameRect(forContentRect: newView.frame)
        newFrame.origin = frame.origin
        newFrame.origin.y +=  frame.height - newFrame.height - toolBar.frame.height
        newFrame.size.height += toolBar.frame.height
        window?.setFrame(newFrame, display: true)
        window?.contentView?.addSubview(newView)
    }
}
