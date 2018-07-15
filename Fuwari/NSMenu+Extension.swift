//
//  NSMenu+Extension.swift
//  Fuwari
//
//  Created by Kengo Yokoyama on 2018/07/14.
//  Copyright © 2018年 AppKnop. All rights reserved.
//

import Cocoa

extension NSMenu {
    func addItem(withTitle title: String, action: Selector? = nil, target: AnyObject? = nil, representedObject: AnyObject? = nil, state: NSControl.StateValue = .off, submenu: NSMenu? = nil) {
        let menuItem = NSMenuItem(title: title, action: action, keyEquivalent: "")
        menuItem.target = target
        menuItem.representedObject = representedObject
        menuItem.state = state
        menuItem.submenu = submenu
        addItem(menuItem)
    }
}
