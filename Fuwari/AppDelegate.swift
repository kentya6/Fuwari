//
//  AppDelegate.swift
//  Fuwari
//
//  Created by Kengo Yokoyama on 2016/11/29.
//  Copyright © 2016年 AppKnop. All rights reserved.
//

import Cocoa
import Carbon
import Magnet

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    let statusItem = NSStatusBar.system().statusItem(withLength: -2)
    var eventMonitor: Any?
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        configureMenu()
        
        if let keyCombo = KeyCombo(keyCode: kVK_ANSI_5, cocoaModifiers: [.shift, .command]) {
            HotKey(identifier: "Capture", keyCombo: keyCombo, target: self, action: #selector(capture)).register()
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    private func configureMenu() {
        if let button = statusItem.button {
            button.image = NSImage(named: "MenuIcon")
        }
        
        let menu = NSMenu()
        
        let captureItem = NSMenuItem(title: "Capture", action: #selector(capture), keyEquivalent: "5")
        captureItem.keyEquivalentModifierMask = [.command, .shift]
        menu.addItem(captureItem)
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Preferences", action: #selector(openPreferences), keyEquivalent: "P"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit Fuwari", action: #selector(quit), keyEquivalent: "q"))
        
        statusItem.menu = menu
    }
    
    @objc private func openPreferences() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationType.Preferences.rawValue), object: nil)
    }
    
    @objc private func capture() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationType.Capture.rawValue), object: nil)
        eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.mouseMoved, .leftMouseUp], handler: {
            (event: NSEvent) in
            switch event.type {
            case .mouseMoved:
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationType.MouseMoved.rawValue), object: nil)
            case .leftMouseUp:
                if let eventMonitor = self.eventMonitor {
                    NSEvent.removeMonitor(eventMonitor)
                    self.eventMonitor = nil
                }
            default:
                break
            }
        })
    }
    
    @objc private func quit() {
        NSApp.terminate(nil)
    }
}
