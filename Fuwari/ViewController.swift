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
    private var fullScreenWindow = FullScreenWindow()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fullScreenWindow.captureDelegate = self
        let controller = NSWindowController(window: fullScreenWindow)
        controller.showWindow(nil)
        windowControllers.append(controller)
        fullScreenWindow.orderOut(nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(didSelectCaptureButton(_:)), name: Notification.Name(rawValue: Constants.Notification.capture), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didSelectPreferencesButton(_:)), name: Notification.Name(rawValue: Constants.Notification.preferences), object: nil)
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
        
        fullScreenWindow.startCapture()
    }
    
    @IBAction private func didSelectPreferencesButton(_: NSButton) {
        
    }
    
    @IBAction private func didSelectQuitButton(_: NSButton) {
        NSApplication.shared().terminate(self)
    }
}

extension ViewController: CaptureDelegate {
    func didCaptured(rect: NSRect, image: CGImage) {
        print(rect.width, rect.height, image.width, image.height)
        createFloatWindow(rect: rect, image: image)
        NSCursor.unhide()
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
        formatter.dateFormat = "yyyyMMddHHmmss"
        savePanel.nameFieldStringValue = "screen_shot_\(formatter.string(from: Date())).png"
        
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
            }
        }
    }
}
