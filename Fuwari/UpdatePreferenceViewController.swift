//
//  UpdatePreferenceViewController.swift
//  Fuwari
//
//  Created by Kengo Yokoyama on 2016/12/11.
//  Copyright © 2016年 AppKnop. All rights reserved.
//

import Cocoa

class UpdatePreferenceViewController: NSViewController {

    @IBOutlet weak var versionTextField: NSTextField!
    
    override func loadView() {
        super.loadView()
        if let versionString = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String {
            versionTextField.stringValue = "v\(versionString)"
        }
    }
}
