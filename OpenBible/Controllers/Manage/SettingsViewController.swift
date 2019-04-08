//
//  SettingsViewController.swift
//  OpenBible
//
//  Created by Denis Dobanda on 14.03.19.
//  Copyright © 2019 Denis Dobanda. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController, Storyboarded {

    weak var coordinator: SettingsCootrinator?
    
    @IBOutlet private weak var numberLabel: UILabel!
    @IBOutlet private weak var stepper: UIStepper!
    @IBOutlet private weak var strongSwitch: UISwitch!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        strongSwitch.isOn = coordinator?.isStrongsOn ?? false
        let v = coordinator?.modulesCount ?? 0
        numberLabel.text = "\(v)"
        stepper.value = Double(v)
    }
    
    @IBAction func steped(_ sender: UIStepper) {
        let v = Int(sender.value)
        coordinator?.modulesCount = v
//        AppDelegate.plistManager.portraitNumber = v
//        AppDelegate.coreManager.update()
        numberLabel.text = "\(v)"
    }
    
    @IBAction func strongSwitched(_ sender: UISwitch) {
//        AppDelegate.plistManager.isStrongsOn = sender.isOn
//        AppDelegate.coreManager.update(true)
        coordinator?.isStrongsOn = sender.isOn
    }
}
