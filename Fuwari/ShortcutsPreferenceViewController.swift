//
//  ShortcutsPreferenceViewController.swift
//  Fuwari
//
//  Created by Kengo Yokoyama on 2016/12/18.
//  Copyright © 2016年 AppKnop. All rights reserved.
//

import Cocoa
import KeyHolder
import Magnet

class ShortcutsPreferenceViewController: NSViewController {
    
    @IBOutlet fileprivate weak var captureShortcutRecordView: RecordView! {
        didSet {
            captureShortcutRecordView.tintColor = .main
        }
    }
    
    override func loadView() {
        super.loadView()
        captureShortcutRecordView.delegate = self
        prepareHotKeys()
    }
    
}

fileprivate extension ShortcutsPreferenceViewController {
    fileprivate func prepareHotKeys() {
        
        captureShortcutRecordView.keyCombo = HotKeyManager.shared.captureKeyCombo
    }
}

extension ShortcutsPreferenceViewController: RecordViewDelegate {
    func recordViewShouldBeginRecording(_ recordView: RecordView) -> Bool {
        return true
    }
    
    func recordView(_ recordView: RecordView, canRecordKeyCombo keyCombo: KeyCombo) -> Bool {
        return true
    }
    
    func recordViewDidClearShortcut(_ recordView: RecordView) {
        switch recordView {
        case captureShortcutRecordView:
            HotKeyManager.shared.registerHotKey(keyCombo: nil)
        default: break
        }
    }
    
    func recordView(_ recordView: RecordView, didChangeKeyCombo keyCombo: KeyCombo) {
        switch recordView {
        case captureShortcutRecordView:
            HotKeyManager.shared.registerHotKey(keyCombo: keyCombo)
        default: break
        }
    }
    
    func recordViewDidEndRecording(_ recordView: RecordView) {}
}
