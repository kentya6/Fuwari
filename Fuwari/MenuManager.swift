//
//  MenuManager.swift
//  Fuwari
//
//  Created by Kengo Yokoyama on 2016/12/25.
//  Copyright © 2016年 AppKnop. All rights reserved.
//

import Cocoa
import Magnet
import Sauce
import Sparkle

class MenuManager: NSObject {

    static let shared = MenuManager()
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    
    private var captureItem = NSMenuItem()

    func configure() {
        if let button = statusItem.button {
            button.image = NSImage(named: "MenuIcon")
        }
        
        captureItem = NSMenuItem(title: LocalizedString.Capture.value, action: #selector(AppDelegate.capture), keyEquivalent: HotKeyManager.shared.captureKeyCombo.characters.lowercased())
        captureItem.keyEquivalentModifierMask = HotKeyManager.shared.captureKeyCombo.modifiers.convertSupportCocoaModifiers()
        
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: LocalizedString.About.value, action: #selector(AppDelegate.openAbout), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: LocalizedString.Preference.value, action: #selector(AppDelegate.openPreferences), keyEquivalent: ","))
        menu.addItem(withTitle: LocalizedString.CheckForUpdates.value,
                     action: #selector(SUUpdater.checkForUpdates(_:)),
                     target: SUUpdater.shared())
        menu.addItem(NSMenuItem.separator())
        menu.addItem(captureItem)
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: LocalizedString.QuitFuwari.value, action: #selector(AppDelegate.quit), keyEquivalent: "q"))
        
        statusItem.menu = menu
    }
    
    func updateCaptureMenuItem() {
        captureItem.keyEquivalent = HotKeyManager.shared.captureKeyCombo.characters.lowercased()
        captureItem.keyEquivalentModifierMask = HotKeyManager.shared.captureKeyCombo.modifiers.convertSupportCocoaModifiers()
    }
}
