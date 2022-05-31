//
//  SpaceMode.swift
//  Fuwari
//
//  Created by Kengo Yokoyama on 2022/05/29.
//  Copyright © 2022 AppKnop. All rights reserved.
//

import Cocoa

enum SpaceMode {
    case all
    case current
    
    func getCollectionBehavior() -> NSWindow.CollectionBehavior {
        switch self {
        case .all:
            return [.canJoinAllSpaces, .stationary, .fullScreenAuxiliary]
        case .current:
            return [.stationary, .fullScreenAuxiliary]
        }
    }
}
