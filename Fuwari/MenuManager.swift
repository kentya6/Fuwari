//
//  MenuManager.swift
//  Fuwari
//
//  Created by Kengo Yokoyama on 2016/12/25.
//  Copyright © 2016年 AppKnop. All rights reserved.
//

import Cocoa

class MenuManager: NSObject {

    static let shared = MenuManager()
    let statusItem = NSStatusBar.system().statusItem(withLength: NSSquareStatusItemLength)

    func configure() {
        if let button = statusItem.button {
            button.image = NSImage(named: "MenuIcon")
        }
        
        let menu = NSMenu()
        let captureItem = NSMenuItem(title: LocalizedString.Capture.value, action: #selector(AppDelegate.capture), keyEquivalent: HotKeyManager.shared.captureKeyCombo.characters)
        captureItem.keyEquivalentModifierMask = NSEventModifierFlags(rawValue: UInt(HotKeyManager.shared.captureKeyCombo.modifiers))
        menu.addItem(captureItem)
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: LocalizedString.Preference.value, action: #selector(AppDelegate.openPreferences), keyEquivalent: ","))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: LocalizedString.QuitFuwari.value, action: #selector(AppDelegate.quit), keyEquivalent: "q"))
        
        statusItem.menu = menu
    }
}
