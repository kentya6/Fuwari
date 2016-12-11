//
//  LocalizedString.swift
//  Fuwari
//
//  Created by Kengo Yokoyama on 2016/12/11.
//  Copyright © 2016年 AppKnop. All rights reserved.
//

import Cocoa

enum LocalizedString: String {
    case Preference             = "Preferences..."
    case QuitClipy              = "Quit Fuwari"
    case Cancel                 = "Cancel"
    case LaunchClipy            = "Launch Fuwari on system startup?"
    case LaunchSettingInfo      = "You can change this setting in the Preferences if you want."
    case LaunchOnStartup        = "Launch on system startup"
    case DontLaunch             = "Don't Launch"
    
    case TabGeneral             = "General"
    case TabMenu                = "Menu"
    case TabShortcuts           = "Shortcuts"
    case TabUpdates             = "Updates"
    
    var value: String {
        return NSLocalizedString(rawValue, comment: "")
    }
}
