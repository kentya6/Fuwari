//
//  FloatView.swift
//  Fuwari
//
//  Created by Kengo Yokoyama on 2018/07/15.
//  Copyright © 2018年 AppKnop. All rights reserved.
//

import Cocoa

class FloatView: NSView {
    private let defaults = UserDefaults.standard
    
    override func viewDidMoveToWindow() {
        if !trackingAreas.isEmpty {
            for area in trackingAreas {
                removeTrackingArea(area)
           }
        }
        if bounds.size.width == 0 || bounds.size.height == 0 { return }
        
        let options: NSTrackingArea.Options = [.activeAlways, .mouseEnteredAndExited]
        addTrackingArea(NSTrackingArea(rect: bounds, options: options, owner: self, userInfo: nil))
     }
    
    override func acceptsFirstMouse(for event: NSEvent?) -> Bool {
        return true
    }
    
    override func mouseDown(with event: NSEvent) {
        let movingOpacity = defaults.float(forKey: Constants.UserDefaults.movingOpacity)
        if movingOpacity < 1 {
            window?.alphaValue = CGFloat(movingOpacity)
        }
    }
    
    override func mouseUp(with event: NSEvent) {
        window?.alphaValue = 1.0
    }
}
