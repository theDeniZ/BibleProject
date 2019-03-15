//
//  SettingsViewController.swift
//  OpenBible
//
//  Created by Denis Dobanda on 14.03.19.
//  Copyright © 2019 Denis Dobanda. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    
    @IBOutlet private weak var numberLabel: UILabel!
    @IBOutlet private weak var stepper: UIStepper!
    @IBOutlet private weak var strongSwitch: UISwitch!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        strongSwitch.isOn = AppDelegate.plistManager.isStrongsOn
        let v = AppDelegate.plistManager.portraitNumber
        numberLabel.text = "\(v)"
        stepper.value = Double(v)
    }
    
    @IBAction func steped(_ sender: UIStepper) {
        let v = Int(sender.value)
        AppDelegate.plistManager.portraitNumber = v
        AppDelegate.coreManager.update()
        numberLabel.text = "\(v)"
    }
    
    @IBAction func strongSwitched(_ sender: UISwitch) {
        AppDelegate.plistManager.isStrongsOn = sender.isOn
        AppDelegate.coreManager.update(true)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
