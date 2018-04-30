//
//  StateManager.swift
//  Fuwari
//
//  Created by Kengo Yokoyama on 2018/04/30.
//  Copyright © 2018年 AppKnop. All rights reserved.
//

import Cocoa

class StateManager: NSObject {
    static let shared = StateManager()
    var isCapturing = false
}
