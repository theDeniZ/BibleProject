//
//  ModuleViewController.swift
//  macB
//
//  Created by Denis Dobanda on 23.12.18.
//  Copyright © 2018 Denis Dobanda. All rights reserved.
//

import Cocoa

class ModuleViewController: NSViewController {

    var moduleManager: CoreManager? {didSet{updateUI()}}
    var currentModule: Module!
    var index: Int!
    var delegate: SplitViewDelegate?
    
    private var textStorage: NSTextStorage?
    private var choise: [String] = []
    
    @IBOutlet private var textView: NSTextView! {didSet{updateUI()}}
    @IBOutlet weak var modulePicker: NSComboBox! {didSet{updateUI()}}
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        updateUI()
    }
    
    private func updateCombo() {
        modulePicker?.removeAllItems()
        modulePicker?.addItem(withObjectValue: currentModule.key ?? currentModule.name ?? "Bible")
        if let keys = moduleManager?.getAllAvailableModulesKey() {
            modulePicker?.addItems(withObjectValues: keys)
            choise = keys
        }
        modulePicker?.selectItem(at: 0)
    }
    
    private func updateUI() {
        updateCombo()
        if let i = index, let strings = moduleManager?[i] {
            let attributedString = strings.reduce(NSMutableAttributedString()) { (r, each) -> NSMutableAttributedString in
                r.append(each)
//                r.append("\n")
                return r
            }
//            if let c = NSColor(named: NSColor.Name("textColor")) {
//                attributedString.addAttribute(.foregroundColor, value: c, range: NSRange(0..<attributedString.length))
//            }
            if let lm = textView?.layoutManager {
                textStorage?.removeLayoutManager(lm)
                textStorage = NSTextStorage(attributedString: attributedString)
                textStorage!.addLayoutManager(lm)
            }
        }
    }
    
    @IBAction func comboPicked(_ sender: NSComboBox) {
        if sender.indexOfSelectedItem > 0 {
            if let m = moduleManager?.setActive(choise[sender.indexOfSelectedItem - 1], at: index) {
                currentModule = m
                updateUI()
            }
        }
    }
    
    override func becomeFirstResponder() -> Bool {
        updateCombo()
        return super.becomeFirstResponder()
    }
    
    @IBAction func closeAction(_ sender: NSButton) {
        delegate?.splitViewWouldLikeToResign(being: index)
    }
    
    
}


extension ModuleViewController: ModelUpdateDelegate {
    func modelChanged() {
        DispatchQueue.main.async { [weak self] in
            self?.updateUI()
        }
    }
}
