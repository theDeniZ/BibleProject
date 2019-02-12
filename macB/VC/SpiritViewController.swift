//
//  SpiritViewController.swift
//  macB
//
//  Created by Denis Dobanda on 21.01.19.
//  Copyright © 2019 Denis Dobanda. All rights reserved.
//

import Cocoa

class SpiritViewController: NSViewController {

    var manager: SpiritManager = SpiritManager()
    var index = 0
    
    @IBOutlet private weak var searchField: NSSearchField!
    @IBOutlet private var textView: NSTextView!
    @IBOutlet weak var containerMenuView: NSSplitView!
    
    private var books: [String] = []
    private var textStorage: NSTextStorage?
    private var menuIsOn = false
    private var listVC: ListViewController?
    
    private var types: [ListType] = [.spirit]
    private var isInSearch: Bool = false
    
    override var acceptsFirstResponder: Bool {return true}
    
    @IBAction private func didSearch(_ sender: NSSearchField) {
        if sender.stringValue.count > 0 {
            isInSearch = true
            manager.doSearch(sender.stringValue)
        } else {
            manager.clearSearch()
            isInSearch = false
        }
    }
    
//    @IBAction open func toggleSidebar(_ sender: Any?) {
//        toggleMenu()
//    }
    
    func toggleMenu() -> Bool {
        menuIsOn = !menuIsOn
        AppDelegate.plistManager.setMenu(isOn: menuIsOn)
        if menuIsOn {
            containerMenuView.insertArrangedSubview(listVC!.view, at: 0)
            containerMenuView.setPosition(containerMenuView.bounds.width * 0.3, ofDividerAt: 0)
        } else {
            containerMenuView.removeArrangedSubview(listVC!.view)
        }
        return menuIsOn
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        manager.index = index
        manager.delegate = self
        updateUI()
        menuIsOn = AppDelegate.plistManager.isMenuOn()
        
        listVC = NSStoryboard.main?.instantiateController(withIdentifier: "List View Controller") as? ListViewController
        if let list = listVC {
            list.typesToDisplay = types
            list.delegate = self
//            if menuIsOn {
//                containerMenuView.insertArrangedSubview(list.view, at: 0)
//                containerMenuView.setPosition(view.bounds.width * 0.3, ofDividerAt: 0)
//            }
//            containerMenuView.addArrangedSubview(list.view)
//            containerMenuView.isHidden = !menuIsOn
        }
    }
    
    
    override func viewWillAppear() {
        super.viewWillAppear()
        if menuIsOn {
            containerMenuView.insertArrangedSubview(listVC!.view, at: 0)
            containerMenuView.setPosition(view.bounds.width * 0.3, ofDividerAt: 0)
        }
        if let w = NSApp.windows.first {
            w.toolbar?.insertItem(withItemIdentifier: .toggleSidebar, at: 0)
        }
//        if let mainWindow = view.window?.windowController as? MainWindowController {
//            mainWindow.setMenuImage(selected: menuIsOn)
//        }
    }
    
    override func viewWillDisappear() {
        super.viewWillDisappear()
        if let w = NSApp.windows.first {
            if w.toolbar?.items[0].itemIdentifier == .toggleSidebar {
                w.toolbar?.removeItem(at: 0)
            }
        }
    }
    
    
    private func updateUI() {
        if !isInSearch {
            searchField.placeholderString = manager.shortPath
            searchField.stringValue = ""
        }
        let textArray = manager.stringValue()
        if textArray.count > 0 {
            let attributedString = textArray.reduce(NSMutableAttributedString()) { (r, each) -> NSMutableAttributedString in
                r.append(each)
                return r
            }
            if let c = NSColor(named: NSColor.Name("textColor")) {
                attributedString.addAttribute(.foregroundColor, value: c, range: NSRange(0..<attributedString.length))
            }
            if let lm = textView?.layoutManager {
                textStorage?.removeLayoutManager(lm)
                textStorage = NSTextStorage(attributedString: attributedString)
                textStorage!.addLayoutManager(lm)
                if let c = NSColor(named: NSColor.Name("linkTextColor")) {
                    textView?.linkTextAttributes = [.foregroundColor: c, .cursor: NSCursor.contextualMenu]
                }
                textView?.setSelectedRange(NSMakeRange(textView.string.count, 0))
            }
        }
    }
    
    
}

extension SpiritViewController: SideMenuDelegate {
    func sideMenuDidSelect(index spIndex: SpiritIndex) {
        self.index = manager.set(spiritIndex: spIndex)
    }
}

extension SpiritViewController: ModelUpdateDelegate {
    func modelChanged() {
        DispatchQueue.main.async {
            self.updateUI()
        }
    }
}

