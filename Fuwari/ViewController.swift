//
//  ViewController.swift
//  Fuwari
//
//  Created by Kengo Yokoyama on 2016/11/29.
//  Copyright © 2016年 AppKnop. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet private weak var versionTextField: NSTextField!
    
    fileprivate var windowControllers = [NSWindowController]()
    fileprivate var fullScreenWindows = [FullScreenWindow]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for (i, screen) in NSScreen.screens()!.enumerated() {
            fullScreenWindows.append(FullScreenWindow())
            fullScreenWindows[i] = FullScreenWindow(contentRect: NSRect(x: screen.frame.origin.x, y: screen.frame.origin.y, width: screen.frame.width, height: screen.frame.height), styleMask: .borderless, backing: .buffered, defer: false)
            fullScreenWindows[i].captureDelegate = self
            
            print(screen.frame, fullScreenWindows[i].frame)
            fullScreenWindows.append(fullScreenWindows[i])
            let controller = NSWindowController(window: fullScreenWindows[i])
            controller.showWindow(nil)
            windowControllers.append(controller)
            fullScreenWindows[i].orderOut(nil)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(didSelectCaptureButton(_:)), name: Notification.Name(rawValue: Constants.Notification.capture), object: nil)
        
        if let versionString = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String {
            versionTextField.stringValue = "Fuwari, v\(versionString)"
        }
    }
    
    fileprivate func createFloatWindow(rect: NSRect, image: CGImage) {
        let floatWindow = FloatWindow(contentRect: rect, image: image)
        floatWindow.floatDelegate = self
        let floatWindowController = NSWindowController(window: floatWindow)
        floatWindowController.showWindow(nil)
        windowControllers.append(floatWindowController)
    }

    @IBAction private func didSelectCaptureButton(_: NSButton) {
        NSCursor.hide()
        
        fullScreenWindows.forEach { fullScreenWindow in
            fullScreenWindow.startCapture()
        }
    }
    
    @IBAction private func didSelectPreferencesButton(_: NSButton) {
        PreferencesWindowController.shared.showWindow(self)
    }
    
    @IBAction private func didSelectQuitButton(_: NSButton) {
        NSApplication.shared().terminate(self)
    }
}

extension ViewController: CaptureDelegate {
    func didCaptured(rect: NSRect, image: CGImage) {
        createFloatWindow(rect: rect, image: image)
        NSCursor.unhide()
        fullScreenWindows.forEach {
            $0.orderOut(nil)
        }
    }
    
    func didCanceled() {
        NSCursor.unhide()
        fullScreenWindows.forEach {
            $0.orderOut(nil)
        }
    }
}

extension ViewController: FloatDelegate {
    func close(floatWindow: FloatWindow) {
        windowControllers.filter({ $0.window === floatWindow }).first?.close()
    }

    func save(floatWindow: FloatWindow, image: CGImage) {
        let savePanel = NSSavePanel()
        savePanel.canCreateDirectories = true
        savePanel.showsTagField = false
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd-HHmmss"
        savePanel.nameFieldStringValue = "screenshot-\(formatter.string(from: Date())).png"
        
        floatWindow.level = Int(CGWindowLevelForKey(.minimumWindow))
        
        savePanel.begin { (result) in
            if result == NSFileHandlingPanelOKButton {
                guard let url = savePanel.url else { return }
                
                let bitmapRep = NSBitmapImageRep(cgImage: image)
                let data = bitmapRep.representation(using: .PNG, properties: [:])
                do {
                    try data?.write(to: url, options: .atomicWrite)
                } catch {
                    print(error.localizedDescription)
                }
            } else {
                floatWindow.level = Int(CGWindowLevelForKey(.maximumWindow))
            }
        }
    }
}
