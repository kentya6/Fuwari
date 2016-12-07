//
//  FullScreenWindow.swift
//  Fuwari
//
//  Created by Kengo Yokoyama on 2016/12/07.
//  Copyright © 2016年 AppKnop. All rights reserved.
//

import Cocoa

class FullScreenWindow: NSWindow {
    
    var captureDelegate: CaptureDelegate?
    
    private lazy var captureGuideView: CaptureGuideView = {
        guard let frame = NSScreen.main()?.frame else { return CaptureGuideView() }
        let captureGuideView = CaptureGuideView(frame: frame)
        return captureGuideView
    }()
    
    override init(contentRect: NSRect, styleMask style: NSWindowStyleMask, backing bufferingType: NSBackingStoreType, defer flag: Bool) {
        guard let frame = NSScreen.main()?.frame else {
            super.init(contentRect: contentRect, styleMask: style, backing: bufferingType, defer: flag)
            return
        }
        super.init(contentRect: frame, styleMask: .borderless, backing: .buffered, defer: false)
        
        isReleasedWhenClosed = true
        displaysWhenScreenProfileChanges = true
        backgroundColor = .clear
        isOpaque = false
        hasShadow = false
        ignoresMouseEvents = false
        acceptsMouseMovedEvents = true
        level = Int(CGWindowLevelForKey(.maximumWindow))
        makeKeyAndOrderFront(self)
        
        contentView = captureGuideView
    }
    
    func startCapture() {
        orderBack(nil)
        captureGuideView.cursorPoint = NSEvent.mouseLocation()
    }
    
    override func mouseMoved(with event: NSEvent) {
        captureGuideView.cursorPoint = event.locationInWindow
    }
    
    override func mouseDown(with event: NSEvent) {
        captureGuideView.startPoint = event.locationInWindow
        captureGuideView.cursorPoint = event.locationInWindow
    }
    
    override func mouseDragged(with event: NSEvent) {
        captureGuideView.cursorPoint = event.locationInWindow
    }
    
    override func mouseUp(with event: NSEvent) {
        capture(rect: captureGuideView.guideWindowRect)
    }
    
    private func capture(rect: NSRect) {
        let windowId = NSApplication.shared().windows[0].windowNumber
        
        let cgRect = CGRect(x: rect.origin.x, y: frame.height - rect.origin.y - rect.height, width: rect.width, height: rect.height)
        guard let cgImage = CGWindowListCreateImage(cgRect, .optionOnScreenBelowWindow, CGWindowID(windowId), .bestResolution) else {
            return
        }
        
        captureGuideView.reset()
        
        orderOut(nil)
        captureDelegate?.didCaptured(rect: rect, image: cgImage)
    }
}

protocol CaptureDelegate {
    func didCaptured(rect: NSRect, image: CGImage)
}
