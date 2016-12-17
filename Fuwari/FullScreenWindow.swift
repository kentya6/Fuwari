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
        let captureGuideView = CaptureGuideView(frame: self.frame)
        return captureGuideView
    }()
    
    override init(contentRect: NSRect, styleMask style: NSWindowStyleMask, backing bufferingType: NSBackingStoreType, defer flag: Bool) {
        super.init(contentRect: contentRect, styleMask: .borderless, backing: .buffered, defer: false)
        
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(mouseMoved(with:)), name: Notification.Name(rawValue: Constants.Notification.mouseMoved), object: nil)
    }
    
    func startCapture() {
        orderBack(nil)
        captureGuideView.cursorPoint = NSPoint(x: NSEvent.mouseLocation().x - frame.origin.x, y: NSEvent.mouseLocation().y)
    }
    
    override func mouseMoved(with event: NSEvent) {
        captureGuideView.cursorPoint = NSPoint(x: NSEvent.mouseLocation().x - frame.origin.x, y: NSEvent.mouseLocation().y - frame.origin.y)
    }
    
    override func mouseDown(with event: NSEvent) {
        captureGuideView.startPoint = NSPoint(x: NSEvent.mouseLocation().x - frame.origin.x, y: NSEvent.mouseLocation().y - frame.origin.y)
        captureGuideView.cursorPoint = NSPoint(x: NSEvent.mouseLocation().x - frame.origin.x, y: NSEvent.mouseLocation().y - frame.origin.y)
    }
    
    override func mouseDragged(with event: NSEvent) {
        captureGuideView.cursorPoint = NSPoint(x: NSEvent.mouseLocation().x - frame.origin.x, y: NSEvent.mouseLocation().y - frame.origin.y)
    }
    
    override func mouseUp(with event: NSEvent) {
        capture(rect: captureGuideView.guideWindowRect)
    }
    
    private func capture(rect: NSRect) {
        var upRightPoint = NSPoint.zero
        
        NSScreen.screens()?.forEach {
            upRightPoint = NSPoint(x: max(upRightPoint.x, $0.frame.origin.x + $0.frame.width), y: max(upRightPoint.y, $0.frame.origin.y + $0.frame.height))
        }
        
        var originY = CGFloat(0)
        if frame.origin.y > 0 {
            originY = upRightPoint.y - frame.origin.y - frame.height - (rect.height + rect.origin.y)
        } else {
            originY = NSScreen.main()!.frame.height - frame.origin.y - (rect.origin.y + rect.height)
        }
        
        let cgRect = CGRect(x: rect.origin.x + frame.origin.x, y: originY, width: rect.width, height: rect.height)
        guard let cgImage = CGWindowListCreateImage(cgRect, .optionOnScreenBelowWindow, CGWindowID(windowNumber), .bestResolution) else {
            return
        }
        
        captureGuideView.reset()
        orderOut(nil)
        
        var captureOffsetY = CGFloat(0)
        if frame.origin.y > 0 {
            captureOffsetY = frame.origin.y - (cgRect.origin.y + cgRect.height)
        } else {
            captureOffsetY = -(cgRect.origin.y - upRightPoint.y + rect.height)
        }
        captureDelegate?.didCaptured(rect: CGRect(x: cgRect.origin.x, y: captureOffsetY, width: cgRect.width, height: cgRect.height), image: cgImage)
    }
}

protocol CaptureDelegate {
    func didCaptured(rect: NSRect, image: CGImage)
}
