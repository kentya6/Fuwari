//
//  ViewController.swift
//  Fuwari
//
//  Created by Kengo Yokoyama on 2016/11/29.
//  Copyright © 2016年 AppKnop. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    fileprivate var windowControllers = [NSWindowController]()
    fileprivate var fullScreenWindows = [FullScreenWindow]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSScreen.screens.forEach {
            let fullScreenWindow = FullScreenWindow(contentRect: $0.frame, styleMask: .borderless, backing: .buffered, defer: false)
            fullScreenWindow.captureDelegate = self
            fullScreenWindows.append(fullScreenWindow)
            let controller = NSWindowController(window: fullScreenWindow)
            controller.showWindow(nil)
            windowControllers.append(controller)
            fullScreenWindow.orderOut(nil)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(startCapture), name: Notification.Name(rawValue: Constants.Notification.capture), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: Notification.Name(rawValue: Constants.Notification.capture), object: nil)
    }
    
    fileprivate func createFloatWindow(rect: NSRect, image: CGImage) {
        let floatWindow = FloatWindow(contentRect: rect, image: image)
        floatWindow.floatDelegate = self
        let floatWindowController = NSWindowController(window: floatWindow)
        floatWindowController.showWindow(nil)
        windowControllers.append(floatWindowController)
    }
    
    @objc private func startCapture() {
        NSCursor.hide()
        
        fullScreenWindows.forEach { $0.startCapture() }
    }
}

extension ViewController: CaptureDelegate {
    func didCaptured(rect: NSRect, image: CGImage) {
        createFloatWindow(rect: rect, image: image)
        NSCursor.unhide()
        fullScreenWindows.forEach { $0.orderOut(nil) }
    }
    
    func didCanceled() {
        NSCursor.unhide()
        fullScreenWindows.forEach { $0.orderOut(nil) }
    }
}

extension ViewController: FloatDelegate {
    func close(floatWindow: FloatWindow) {
        windowControllers.filter({ $0.window === floatWindow }).first?.close()
    }

    func save(floatWindow: FloatWindow, image: CGImage) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd-HHmmss"
        
        let savePanel = NSSavePanel()
        savePanel.canCreateDirectories = true
        savePanel.showsTagField = false
        savePanel.nameFieldStringValue = "screenshot-\(formatter.string(from: Date())).png"
        savePanel.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.modalPanelWindow)))
        savePanel.begin { (result) in
            if result.rawValue == NSFileHandlingPanelOKButton {
                guard let url = savePanel.url else { return }
                
                let bitmapRep = NSBitmapImageRep(cgImage: image)
                let data = bitmapRep.representation(using: .png, properties: [:])
                do {
                    try data?.write(to: url, options: .atomicWrite)
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
    }
}
