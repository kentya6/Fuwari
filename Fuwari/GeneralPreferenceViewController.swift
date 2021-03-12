//
//  GeneralPreferenceViewController.swift
//  Fuwari
//
//  Created by sho on 2021/03/12.
//  Copyright © 2021 AppKnop. All rights reserved.
//

import Cocoa

class GeneralPreferenceViewController: NSViewController {
    private let defaults = UserDefaults.standard
    
    @IBOutlet weak var movingOpacityValue: NSTextField!
    
    private func toPercentageString(_ value: Float) -> String {
        return String(Int(value * 100)) + "%"
    }
    
    @IBAction func sliderValue(_ sender: NSSlider) {
        movingOpacityValue.stringValue = toPercentageString(sender.floatValue)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let movingOpacity = defaults.float(forKey: Constants.UserDefaults.movingOpacity)
        movingOpacityValue.stringValue = toPercentageString(movingOpacity)
    }
}
