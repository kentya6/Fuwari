//
//  Constants.swift
//  Fuwari
//
//  Created by Kengo Yokoyama on 2016/12/09.
//  Copyright © 2016年 AppKnop. All rights reserved.
//

import Cocoa

struct Constants {
    struct Notification {
        static let capture     = "capture"
        static let mouseMoved  = "mouseMoved"
    }
    
    struct UserDefaults {
        static let loginItem                 = "loginItem"
        static let suppressAlertForLoginItem = "suppressAlertForLoginItem"
        static let uploadConfirmationItem    = "uploadConfirmationItem"
        static let captureKeyCombo           = "captureKeyCombo"
        static let movingOpacity             = "movingOpacity"
    }
    
    struct ImageName {
        static let generalOff = "General"
        static let generalOn  = "GeneralOn"        
        static let shortcutOff = "Shortcut"
        static let shortcutOn  = "ShortcutOn"
    }
    
    struct HotKey {
        static let capture = "capture"
    }
}
