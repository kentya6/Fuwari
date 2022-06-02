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
    
    private let defaults = UserDefaults.standard
    
    @IBOutlet private weak var captureShortcutRecordView: RecordView! {
        didSet {
            captureShortcutRecordView.tintColor = .main
        }
    }
    
    @IBOutlet private weak var singleTapCaptureButton: NSPopUpButton!
    @IBOutlet private weak var doubleTapCaptureButton: NSPopUpButton!
            
    override func loadView() {
        super.loadView()
        captureShortcutRecordView.delegate = self
        prepareHotKeys()
        
        defaults.register(defaults: [Constants.UserDefaults.singleTapCaptureMode: SpaceMode.all.rawValue])
        defaults.register(defaults: [Constants.UserDefaults.doubleTapCaptureMode: SpaceMode.current.rawValue])
        
        singleTapCaptureButton.addItems(withTitles: [LocalizedString.ShowAllSpaces.value, LocalizedString.ShowCurrentSpace.value])
        doubleTapCaptureButton.addItems(withTitles: [LocalizedString.ShowAllSpaces.value, LocalizedString.ShowCurrentSpace.value])
        
        singleTapCaptureButton.selectItem(at: defaults.integer(forKey: Constants.UserDefaults.singleTapCaptureMode))
        doubleTapCaptureButton.selectItem(at: defaults.integer(forKey: Constants.UserDefaults.doubleTapCaptureMode))
    }
    
    @IBAction private func didSelectCaptureButton(_ sender: NSPopUpButton) {
        if sender == singleTapCaptureButton {
            defaults.set(sender.indexOfSelectedItem, forKey: Constants.UserDefaults.singleTapCaptureMode)
        }
        if sender == doubleTapCaptureButton {
            defaults.set(sender.indexOfSelectedItem, forKey: Constants.UserDefaults.doubleTapCaptureMode)
        }
    }
}

private extension ShortcutsPreferenceViewController {
    func prepareHotKeys() {
        
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
    
    func recordView(_ recordView: RecordView, didChangeKeyCombo keyCombo: KeyCombo?) {
        switch recordView {
        case captureShortcutRecordView:
            HotKeyManager.shared.registerHotKey(keyCombo: keyCombo)
        default: break
        }
    }
    
    func recordViewDidEndRecording(_ recordView: RecordView) {}
}
