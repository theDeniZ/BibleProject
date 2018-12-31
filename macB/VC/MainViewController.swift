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
    @IBOutlet weak var textField: NSTextField!
    @IBAction func addButton(_ sender: NSButton) {
        addVC()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        AppDelegate.shared.urlDelegate = self
        updateUI()
        manager.addDelegate(self)
    }
    
    @IBAction func textFieldDidEnter(_ sender: NSTextField) {
        let text = sender.stringValue
        if let match = text.capturedGroups(withRegex: String.regexForBookRefference),
            match.count > 0 {
            if manager.changeBook(by: match[0]),
                match.count > 1,
                let n = Int(match[1]) {
                manager.changeChapter(to: n)
            }
        }
        updateUI()
    }
    
    private func updateUI() {
        textField?.stringValue = ""
        textField?.placeholderString = manager.description
        if displayedModuleControllers.count == 0 {
            addVC()
        }
    }
    
    private func addVC() {
        if let available = manager.createNewActiveModule() {
            if let newVC = NSStoryboard.main?.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("Module VC")) as? ModuleViewController {
                newVC.moduleManager = manager
                newVC.currentModule = available.0
                newVC.index = available.1
                displayedModuleControllers.append(newVC)
                splitView.addArrangedSubview(newVC.view)
                manager.addDelegate(newVC)
            }
        }
    }

}

extension MainViewController: ModelUpdateDelegate {
    func modelChanged() {
        DispatchQueue.main.async { [weak self] in
            self?.updateUI()
        }
    }
}

extension MainViewController: URLDelegate {
    func openedURL(with parameters: [String]) {
        if let vc = NSStoryboard.main?.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("Detail Strong VC")) as? StrongDetailViewController {
            var numbers: [Int] = []
            let identifier = parameters[0]
            let numbersString = parameters[1].split(separator: "+")
            for n in numbersString {
                numbers.append(Int(String(n))!)
            }
            vc.numbers = numbers
            vc.identifierStrong = identifier
            presentAsModalWindow(vc)
        }
    }
}
