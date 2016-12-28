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

    var eventMonitor: Any?
    let defaults = UserDefaults.standard
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        Fabric.with([Answers.self, Crashlytics.self])
        
        // Show Login Item
        if !defaults.bool(forKey: Constants.UserDefaults.loginItem) && !defaults.bool(forKey: Constants.UserDefaults.suppressAlertForLoginItem) {
            promptToAddLoginItems()
        }

        HotKeyManager.shared.configure()
        MenuManager.shared.configure()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        HotKeyCenter.shared.unregisterAll()
    }

    @objc func openPreferences() {
        NSApp.activate(ignoringOtherApps: true)
        PreferencesWindowController.shared.showWindow(self)
    }
    
    @objc func openAbout() {
        NSApp.activate(ignoringOtherApps: true)
        AboutWindowController.shared.showWindow(self)
    }
    
    @objc func capture() {
        NSApp.activate(ignoringOtherApps: true)
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
    
    @objc func quit() {
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
