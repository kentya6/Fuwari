//
//  CaptureGuideView.swift
//  Fuwari
//
//  Created by Kengo Yokoyama on 2016/12/05.
//  Copyright © 2016年 AppKnop. All rights reserved.
//

import Cocoa

class CaptureGuideView: NSView {

    public var delegate: CaptureDelegate?
    
    private var startPoint = NSPoint.zero
    private var currentPoint = NSPoint.zero
    private var guideWindowRect = NSRect.zero
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        NSColor.clear.set()
        NSRectFill(frame)
        
        guideWindowRect = NSRect(x: fmin(startPoint.x, currentPoint.x), y: fmin(startPoint.y, currentPoint.y), width: fabs(currentPoint.x - startPoint.x), height: fabs(currentPoint.y - startPoint.y))
        NSColor(red: 0, green: 0, blue: 0, alpha: 0.25).set()
        NSRectFill(guideWindowRect)
        
        NSColor.white.set()
        NSFrameRectWithWidth(guideWindowRect, 1.0)
    }
    
    override func mouseDown(with event: NSEvent) {
        startPoint = event.locationInWindow
    }
    
    override func mouseDragged(with event: NSEvent) {
        currentPoint = event.locationInWindow
        needsDisplay = true
    }
    
    override func mouseUp(with event: NSEvent) {
        capture(rect: guideWindowRect)
    }
    
    private func capture(rect: NSRect) {        
        let windowId = NSApplication.shared().windows[0].windowNumber
        
        let cgRect = CGRect(x: rect.origin.x, y: frame.height - rect.origin.y - rect.height, width: rect.width, height: rect.height)
        guard let cgImage = CGWindowListCreateImage(cgRect, .optionOnScreenBelowWindow, CGWindowID(windowId), .bestResolution) else {
            return
        }

        startPoint = .zero
        currentPoint = .zero
        guideWindowRect = .zero
        needsDisplay = true
        
        delegate?.didCaptured(rect: rect, image: cgImage)
    }
}

protocol CaptureDelegate {
    func didCaptured(rect: NSRect, image: CGImage)
}
