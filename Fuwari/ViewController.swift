//
//  ViewController.swift
//  Fuwari
//
//  Created by Kengo Yokoyama on 2016/11/29.
//  Copyright © 2016年 AppKnop. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction private func didSelectCaptureButton(_: NSButton) {
        
    }
    
    @IBAction private func didSelectPreferencesButton(_: NSButton) {
        
    }
    
    @IBAction private func didSelectQuitButton(_: NSButton) {
        NSApplication.shared().terminate(self)
    }
}

