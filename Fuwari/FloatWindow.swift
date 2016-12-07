//
//  FloatWindow.swift
//  Fuwari
//
//  Created by Kengo Yokoyama on 2016/12/07.
//  Copyright © 2016年 AppKnop. All rights reserved.
//

import Cocoa
import Carbon

class FloatWindow: NSWindow {

    override var canBecomeKey: Bool { return true }
    override var canBecomeMain: Bool { return true }

    var floatDelegate: FloatDelegate?
    private var image: CGImage?
    
    init(contentRect: NSRect, styleMask style: NSWindowStyleMask = .borderless, backing bufferingType: NSBackingStoreType = .buffered, defer flag: Bool = false, image: CGImage) {
        super.init(contentRect: contentRect, styleMask: style, backing: bufferingType, defer: flag)
        
        level = Int(CGWindowLevelForKey(.maximumWindow))
        isMovableByWindowBackground = true
        hasShadow = true
        
        let nsImage = NSImage(cgImage: image, size: contentRect.size)
        backgroundColor = NSColor(patternImage: nsImage)
        
        self.image = image
    }
    
    override func keyDown(with event: NSEvent) {
        super.keyDown(with: event)
        
        if event.modifierFlags.rawValue & NSEventModifierFlags.command.rawValue != 0 {
            switch event.keyCode {
            case UInt16(kVK_ANSI_S):
                if let image = image {
                    floatDelegate?.save(floatWindow: self, image: image)
                }
            case UInt16(kVK_ANSI_W):
                floatDelegate?.close(floatWindow: self)
            default:
                break
            }
        }
    }
}

protocol FloatDelegate {
    func save(floatWindow: FloatWindow, image: CGImage)
    func close(floatWindow: FloatWindow)
}
