//
//  SettingsViewController.swift
//  macB
//
//  Created by Denis Dobanda on 06.01.19.
//  Copyright © 2019 Denis Dobanda. All rights reserved.
//

import Cocoa

class SettingsViewController: NSViewController {

    @IBOutlet weak var strongsSwitch: NSButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    @IBAction func strongsCheck(_ sender: NSButton) {
        AppDelegate.coreManager.strongsNumbersIsOn = sender.state.rawValue != 0
    }
}
