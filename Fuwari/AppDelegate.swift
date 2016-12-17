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
import LoginServiceKit
import Fabric
import Crashlytics

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    let statusItem = NSStatusBar.system().statusItem(withLength: NSSquareStatusItemLength)
    var eventMonitor: Any?
    let defaults = UserDefaults.standard
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        Fabric.with([Answers.self, Crashlytics.self])

        configureMenu()
        
        if let keyCombo = KeyCombo(keyCode: kVK_ANSI_6, cocoaModifiers: [.shift, .command]) {
            HotKey(identifier: "Capture", keyCombo: keyCombo, target: self, action: #selector(capture)).register()
        }
        
        // Show Login Item
        if !defaults.bool(forKey: Constants.UserDefaults.loginItem) && !defaults.bool(forKey: Constants.UserDefaults.suppressAlertForLoginItem) {
            promptToAddLoginItems()
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        HotKeyCenter.shared.unregisterAll()
    }
    
    private func configureMenu() {
        if let button = statusItem.button {
            button.image = NSImage(named: "MenuIcon")
        }
        
        let menu = NSMenu()
        
        let captureItem = NSMenuItem(title: LocalizedString.Capture.value, action: #selector(capture), keyEquivalent: "5")
        captureItem.keyEquivalentModifierMask = [.command, .shift]
        menu.addItem(captureItem)
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: LocalizedString.Preference.value, action: #selector(openPreferences), keyEquivalent: ","))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: LocalizedString.QuitFuwari.value, action: #selector(quit), keyEquivalent: "q"))
        
        statusItem.menu = menu
    }
    
    @objc private func openPreferences() {
        NSApp.activate(ignoringOtherApps: true)
        PreferencesWindowController.shared.showWindow(self)
    }
    
    @objc private func capture() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.Notification.capture), object: nil)
        eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.mouseMoved, .leftMouseUp], handler: {
            (event: NSEvent) in
            switch event.type {
            case .mouseMoved:
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.Notification.mouseMoved), object: nil)
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
    
    fileprivate func promptToAddLoginItems() {
        let alert = NSAlert()
        alert.messageText = LocalizedString.LaunchFuwari.value
        alert.informativeText = LocalizedString.LaunchSettingInfo.value
        alert.addButton(withTitle: LocalizedString.LaunchOnStartup.value)
        alert.addButton(withTitle: LocalizedString.DontLaunch.value)
        alert.showsSuppressionButton = true
        NSApp.activate(ignoringOtherApps: true)
        
        //  Launch on system startup
        if alert.runModal() == NSAlertFirstButtonReturn {
            defaults.set(true, forKey: Constants.UserDefaults.loginItem)
            toggleLoginItemState()
        }
        // Do not show this message again
        if alert.suppressionButton?.state == NSOnState {
            defaults.set(true, forKey: Constants.UserDefaults.suppressAlertForLoginItem)
        }
        defaults.synchronize()
    }
    
    fileprivate func toggleAddingToLoginItems(_ enable: Bool) {
        let appPath = Bundle.main.bundlePath
        LoginServiceKit.removeLoginItems(at: appPath)
        if enable {
            LoginServiceKit.addLoginItems(at: appPath)
        }
    }
    
    fileprivate func toggleLoginItemState() {
        let isInLoginItems = defaults.bool(forKey: Constants.UserDefaults.loginItem)
        toggleAddingToLoginItems(isInLoginItems)
    }
}
