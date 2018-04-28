//
//  FullScreenWindow.swift
//  Fuwari
//
//  Created by Kengo Yokoyama on 2016/12/07.
//  Copyright © 2016年 AppKnop. All rights reserved.
//

import Cocoa
import Carbon

class FullScreenWindow: NSWindow {
    
    var captureDelegate: CaptureDelegate?
    
    private lazy var captureGuideView: CaptureGuideView = {
        let captureGuideView = CaptureGuideView(frame: self.frame)
        return captureGuideView
    }()
    
    private var mouseLocation: NSPoint {
        return NSPoint(x: NSEvent.mouseLocation.x - frame.origin.x, y: NSEvent.mouseLocation.y - frame.origin.y)
    }
    
    override init(contentRect: NSRect, styleMask style: NSWindow.StyleMask, backing bufferingType: NSWindow.BackingStoreType, defer flag: Bool) {
        super.init(contentRect: contentRect, styleMask: .borderless, backing: .buffered, defer: false)
        
        isReleasedWhenClosed = true
        displaysWhenScreenProfileChanges = true
        backgroundColor = .clear
        isOpaque = false
        hasShadow = false
        ignoresMouseEvents = false
        acceptsMouseMovedEvents = true
        level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.assistiveTechHighWindow)))
        makeKeyAndOrderFront(self)
        
        contentView = captureGuideView
        
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) {
            (event: NSEvent) -> NSEvent? in
            if event.keyCode == UInt16(kVK_Escape) {
                self.captureDelegate?.didCanceled()
            }
            return event
        }
    }
    
    func startCapture() {
        orderBack(nil)
        captureGuideView.cursorPoint = mouseLocation
    }
    
    override func mouseMoved(with event: NSEvent) {
        captureGuideView.cursorPoint = mouseLocation
    }
    
    override func mouseDown(with event: NSEvent) {
        captureGuideView.startPoint = mouseLocation
        captureGuideView.cursorPoint = mouseLocation
    }
    
    override func mouseDragged(with event: NSEvent) {
        captureGuideView.cursorPoint = mouseLocation
    }
    
    override func mouseUp(with event: NSEvent) {
        capture(rect: captureGuideView.guideWindowRect)
    }
    
    private func capture(rect: NSRect) {
        let mainDisplayBounds = CGDisplayBounds(CGMainDisplayID())
        var captureRect = NSRectToCGRect(convertToScreen(rect))
        captureRect.origin.y = mainDisplayBounds.height - captureRect.origin.y - captureRect.height
        
        guard let cgImage = CGWindowListCreateImage(captureRect, .optionOnScreenBelowWindow, CGWindowID(windowNumber), .bestResolution) else {
            return
        }
        
        captureGuideView.reset()
        orderOut(nil)

        captureDelegate?.didCaptured(rect: rect.offsetBy(dx: frame.origin.x, dy: frame.origin.y), image: cgImage)
    }
}

protocol CaptureDelegate {
    func didCanceled()
    func didCaptured(rect: NSRect, image: CGImage)
}
