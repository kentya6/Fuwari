//
//  PreferencesWindowController.swift
//  Fuwari
//
//  Created by Kengo Yokoyama on 2016/12/11.
//  Copyright © 2016年 AppKnop. All rights reserved.
//

import Cocoa

class PreferencesWindowController: NSWindowController {

    static let shared = PreferencesWindowController(windowNibName: NSNib.Name(rawValue: "PreferencesWindowController"))
    
    @IBOutlet fileprivate weak var toolBar: NSView!
    @IBOutlet fileprivate weak var generalImageView: NSImageView!
    @IBOutlet fileprivate weak var shortcutImageView: NSImageView!
    @IBOutlet fileprivate weak var generalTextField: NSTextField!
    @IBOutlet fileprivate weak var shortcutTextField: NSTextField!
    @IBOutlet fileprivate weak var generalButton: NSButton!
    @IBOutlet fileprivate weak var shortcutButton: NSButton!
    
    fileprivate let defaults = UserDefaults.standard
    fileprivate let viewController = [NSViewController(nibName: NSNib.Name(rawValue: "GeneralPreferenceViewController"), bundle: nil),
                                      ShortcutsPreferenceViewController(nibName: NSNib.Name(rawValue: "ShortcutsPreferenceViewController"), bundle: nil)]
    
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
fileprivate extension PreferencesWindowController {
    private func resetImages() {
        generalImageView.image = NSImage(named: NSImage.Name(rawValue: Constants.ImageName.generalOff))
        shortcutImageView.image = NSImage(named: NSImage.Name(rawValue: Constants.ImageName.shortcutOff))
        
        generalTextField.textColor = .tabTitle
        shortcutTextField.textColor = .tabTitle
    }
    
    func selectedTab(_ index: Int) {
        resetImages()
        
        switch index {
        case 0:
            generalImageView.image = NSImage(named: NSImage.Name(rawValue: Constants.ImageName.generalOn))
            generalTextField.textColor = .main
        case 1:
            shortcutImageView.image = NSImage(named: NSImage.Name(rawValue: Constants.ImageName.shortcutOn))
            shortcutTextField.textColor = .main
        default: break
        }
    }
    
    fileprivate func switchView(_ index: Int) {
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
