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
