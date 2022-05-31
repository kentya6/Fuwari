//
//  FloatView.swift
//  Fuwari
//
//  Created by Kengo Yokoyama on 2018/07/15.
//  Copyright © 2018年 AppKnop. All rights reserved.
//

import Cocoa

class FloatView: NSView {
    override func viewDidMoveToWindow() {
        updateTrackingAreas()
    }
    
    override func resizeSubviews(withOldSize oldSize: NSSize) {
        updateTrackingAreas()
    }
    
    override func acceptsFirstMouse(for event: NSEvent?) -> Bool {
        return true
    }
    
    override func updateTrackingAreas() {
        if !trackingAreas.isEmpty {
            for area in trackingAreas {
                removeTrackingArea(area)
           }
        }
        if bounds.size.width == 0 || bounds.size.height == 0 { return }
        
        let options: NSTrackingArea.Options = [.activeAlways, .mouseEnteredAndExited]
        addTrackingArea(NSTrackingArea(rect: bounds, options: options, owner: self, userInfo: nil))
    }
}
