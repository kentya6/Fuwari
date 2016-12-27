//
//  CaptureGuideView.swift
//  Fuwari
//
//  Created by Kengo Yokoyama on 2016/12/05.
//  Copyright © 2016年 AppKnop. All rights reserved.
//

import Cocoa

class CaptureGuideView: NSView {

    var startPoint = NSPoint.zero {
        didSet {
            needsDisplay = true
        }
    }
    
    var cursorPoint = NSPoint.zero {
        didSet {
            needsDisplay = true
        }
    }
    
    var guideWindowRect = NSRect.zero
    
    private let cursorFont = NSFont.systemFont(ofSize: 10.0)
    private let cursorSize = CGFloat(25.0)
    private let cursorGuideWidth = CGFloat(1.0)
    private lazy var coordinateLabelShadow: NSShadow = {
        let shadow = NSShadow()
        shadow.shadowColor = NSColor(red: 1, green: 1, blue: 1, alpha: 0.5)
        shadow.shadowOffset = NSSize(width: 1, height: -1)
        return shadow
    }()
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        drawCaptureArea()
        drawCursor()
    }
    
    private func drawCaptureArea() {
        if startPoint != .zero {
            NSColor(red: 0, green: 0, blue: 0, alpha: 0.25).set()
            guideWindowRect = NSRect(x: floor(fmin(startPoint.x, cursorPoint.x)), y: floor(fmin(startPoint.y, cursorPoint.y)), width: floor(fabs(cursorPoint.x - startPoint.x)), height: floor(fabs(cursorPoint.y - startPoint.y)))
            NSRectFill(guideWindowRect)
            
            NSColor.white.set()
            NSFrameRectWithWidth(guideWindowRect, cursorGuideWidth)
        }
    }
    
    private func drawCursor() {
        NSColor.darkGray.set()
        let cursorRectWidth = NSRect(x: cursorPoint.x - cursorSize / 2, y: cursorPoint.y, width: cursorSize, height: 1)
        NSRectFill(cursorRectWidth)
        let cursorRectHeight = NSRect(x: cursorPoint.x, y: cursorPoint.y - cursorSize / 2, width: 1, height: cursorSize)
        NSRectFill(cursorRectHeight)
        
        NSColor(red: 0, green: 0, blue: 0, alpha: 0.25).set()
        let cursorCenter = NSRect(x: cursorPoint.x - cursorSize / 4 + cursorGuideWidth / 2, y: cursorPoint.y - cursorSize / 4 + cursorGuideWidth / 2, width: cursorSize / 2, height: cursorSize / 2)
        let path = NSBezierPath(ovalIn: cursorCenter)
        path.fill()
        
        (Int(cursorPoint.x).description as NSString).draw(at: NSPoint(x: cursorPoint.x + cursorSize / 2, y: cursorPoint.y - cursorSize / 2), withAttributes: [NSFontAttributeName : cursorFont, NSShadowAttributeName : coordinateLabelShadow])
        (Int(frame.height - cursorPoint.y).description as NSString).draw(at: NSPoint(x: cursorPoint.x + cursorSize / 2, y: cursorPoint.y - cursorSize), withAttributes: [NSFontAttributeName : cursorFont, NSShadowAttributeName : coordinateLabelShadow])
    }
    
    func reset() {
        startPoint = .zero
        cursorPoint = .zero
        guideWindowRect = .zero
    }
}
