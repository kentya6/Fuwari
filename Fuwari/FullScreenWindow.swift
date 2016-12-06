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
    
    override init(contentRect: NSRect, styleMask style: NSWindowStyleMask, backing bufferingType: NSBackingStoreType, defer flag: Bool) {
        guard let frame = NSScreen.main()?.frame else {
            super.init(contentRect: contentRect, styleMask: .borderless, backing: .buffered, defer: false)
            return
        }
        super.init(contentRect: frame, styleMask: .borderless, backing: .buffered, defer: false)
        
        isReleasedWhenClosed = true
        displaysWhenScreenProfileChanges = true
        backgroundColor = .clear
        isOpaque = false
        hasShadow = false
        ignoresMouseEvents = false
        level = Int(CGWindowLevelForKey(.maximumWindow))
        makeKeyAndOrderFront(self)
        
        let fullScreenView = CaptureGuideView(frame: frame)
        fullScreenView.delegate = self
        contentView = fullScreenView
    }
    
    func startCapture() {
        orderFront(nil)
    }
}

extension FullScreenWindow: CaptureDelegate {
    func didCaptured(rect: NSRect, image: NSImage) {
        orderOut(nil)
        captureDelegate?.didCaptured(rect: rect, image: image)
    }
}
