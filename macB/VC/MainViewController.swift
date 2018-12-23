//
//  MainViewController.swift
//  macB
//
//  Created by Denis Dobanda on 23.12.18.
//  Copyright © 2018 Denis Dobanda. All rights reserved.
//

import Cocoa

class MainViewController: NSViewController {

    var manager: CoreManager = AppDelegate.coreManager
    private var displayedModuleControllers: [ModuleViewController] = []
    
    @IBOutlet weak var splitView: NSSplitView!
    
    @IBAction func addButton(_ sender: NSButton) {
        addVC()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addVC()
    }
    
    private func addVC() {
        if let available = manager.createNewActiveModule() {
            if let newVC = NSStoryboard.main?.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("Module VC")) as? ModuleViewController {
                newVC.moduleManager = manager
                newVC.currentModule = available.0
                newVC.index = available.1
                displayedModuleControllers.append(newVC)
                splitView.addArrangedSubview(newVC.view)
            }
        }
    }
    
}
