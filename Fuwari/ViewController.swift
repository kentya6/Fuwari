//
//  ViewController.swift
//  Fuwari
//
//  Created by Kengo Yokoyama on 2016/11/29.
//  Copyright © 2016年 AppKnop. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    private var windowControllers = [NSWindowController]()
    private var fullScreenWindow = FullScreenWindow()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fullScreenWindow.captureDelegate = self
        let controller = NSWindowController(window: fullScreenWindow)
        controller.showWindow(nil)
        windowControllers.append(controller)
        fullScreenWindow.orderOut(nil)
    }
    
    fileprivate func createFloatWindow(rect: NSRect, image: NSImage) {
        let floatWindow = NSWindow(contentRect: rect, styleMask: .borderless, backing: .buffered, defer: false)
        floatWindow.level = Int(CGWindowLevelForKey(.maximumWindow))
        floatWindow.isMovableByWindowBackground = true
        floatWindow.backgroundColor = NSColor(patternImage: image)
        floatWindow.hasShadow = true
        let floatWindowController = NSWindowController(window: floatWindow)
        floatWindowController.showWindow(nil)
        windowControllers.append(floatWindowController)
    }

    @IBAction private func didSelectCaptureButton(_: NSButton) {
        
        fullScreenWindow.startCapture()
    }
    
    @IBAction private func didSelectPreferencesButton(_: NSButton) {
        
    }
    
    @IBAction private func didSelectQuitButton(_: NSButton) {
        NSApplication.shared().terminate(self)
    }
}

extension ViewController: CaptureDelegate {
    func didCaptured(rect: NSRect, image: NSImage) {
        print(rect.width, rect.height, image.size.width, image.size.height)
        createFloatWindow(rect: rect, image: image)
    }
}
