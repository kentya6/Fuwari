//
//  AppDelegate.swift
//  Fuwari
//
//  Created by Kengo Yokoyama on 2016/11/29.
//  Copyright © 2016年 AppKnop. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    let statusItem = NSStatusBar.system().statusItem(withLength: -2)
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        configureMenu()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    private func configureMenu() {
        if let button = statusItem.button {
            button.image = NSImage(named: "MenuIcon")
        }
        
        let menu = NSMenu()
        
        menu.addItem(NSMenuItem(title: "Capture", action: #selector(capture), keyEquivalent: "5"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Preferences", action: #selector(openPreferences), keyEquivalent: "P"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit Fuwari", action: #selector(quit), keyEquivalent: "q"))
        
        statusItem.menu = menu
    }
    
    @objc private func openPreferences(sender: Any) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationType.Preferences.rawValue), object: nil)
    }
    
    @objc private func capture(sender: Any) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationType.Capture.rawValue), object: nil)
    }
    
    @objc private func quit(sender: Any) {
        NSApp.terminate(nil)
    }
}

