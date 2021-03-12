//
//  HotKeyManager.swift
//  Fuwari
//
//  Created by Kengo Yokoyama on 2016/12/18.
//  Copyright © 2016年 AppKnop. All rights reserved.
//

import Foundation
import Magnet
import Carbon

final class HotKeyManager: NSObject {
    
    static let shared = HotKeyManager()
    fileprivate let defaults = UserDefaults.standard
    
    fileprivate(set) lazy var captureKeyCombo: KeyCombo = {
        if let keyCombo = self.defaults.archiveDataForKey(KeyCombo.self, key: Constants.UserDefaults.captureKeyCombo) {
            return keyCombo
        } else {
            let defaultKeyCombo = KeyCombo(keyCode: kVK_ANSI_5, cocoaModifiers: [.command, .shift])!
            self.defaults.setArchiveData(defaultKeyCombo, forKey: Constants.UserDefaults.captureKeyCombo)
            self.defaults.synchronize()
            return defaultKeyCombo
        }
    }()
    fileprivate(set) var captureHotKey: HotKey?
    
    func configure() {
        registerHotKey(keyCombo: captureKeyCombo)
    }
}

extension HotKeyManager {
    func registerHotKey(keyCombo: KeyCombo?) {
        saveKeyCombo(keyCombo: keyCombo)
        
        HotKeyCenter.shared.unregisterHotKey(with: Constants.HotKey.capture)
        guard let keyCombo = keyCombo else { return }
        captureKeyCombo = keyCombo
        
        let hotKey = HotKey(identifier: Constants.HotKey.capture, keyCombo: keyCombo, target: AppDelegate(), action: #selector(AppDelegate.capture))
        hotKey.register()
        captureHotKey = hotKey
        
        MenuManager.shared.updateCaptureMenuItem()
    }
    
    fileprivate func saveKeyCombo(keyCombo: KeyCombo?) {
        if let keyCombo = keyCombo {
            defaults.setArchiveData(keyCombo, forKey: Constants.UserDefaults.captureKeyCombo)
        } else {
            defaults.removeObject(forKey: Constants.UserDefaults.captureKeyCombo)
        }
        defaults.synchronize()
    }
}
