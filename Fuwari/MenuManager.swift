//
//  MenuManager.swift
//  Fuwari
//
//  Created by Kengo Yokoyama on 2016/12/25.
//  Copyright © 2016年 AppKnop. All rights reserved.
//

import Cocoa
import Magnet

class MenuManager: NSObject {

    static let shared = MenuManager()
    let statusItem = NSStatusBar.system().statusItem(withLength: NSSquareStatusItemLength)
    
    private var captureItem = NSMenuItem()

    func configure() {
        if let button = statusItem.button {
            button.image = NSImage(named: "MenuIcon")
        }
        
        captureItem = NSMenuItem(title: LocalizedString.Capture.value, action: #selector(AppDelegate.capture), keyEquivalent: HotKeyManager.shared.captureKeyCombo.characters.lowercased())
        captureItem.keyEquivalentModifierMask = KeyTransformer.cocoaFlags(from: HotKeyManager.shared.captureKeyCombo.modifiers)
        
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: LocalizedString.About.value, action: #selector(AppDelegate.openAbout), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(captureItem)
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: LocalizedString.Preference.value, action: #selector(AppDelegate.openPreferences), keyEquivalent: ","))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: LocalizedString.QuitFuwari.value, action: #selector(AppDelegate.quit), keyEquivalent: "q"))
        
        statusItem.menu = menu
    }
    
    func udpateCpatureMenuItem() {
        statusItem.menu?.items[2].keyEquivalent = HotKeyManager.shared.captureKeyCombo.characters.lowercased()
        statusItem.menu?.items[2].keyEquivalentModifierMask = KeyTransformer.cocoaFlags(from: HotKeyManager.shared.captureKeyCombo.modifiers)
    }
}
