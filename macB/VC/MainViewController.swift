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
    @IBOutlet weak var textField: NSSearchField!
    @IBAction func addButton(_ sender: NSButton) {
        addVC()
    }
    private var listVC: OutlineViewController?
    private lazy var isMenuOn = AppDelegate.plistManager.isMenuOn()
    
    private var plistManager: PlistManager {
        return AppDelegate.plistManager
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        listVC = NSStoryboard.main?.instantiateController(withIdentifier: "Outline View Controller") as? OutlineViewController
        if let list = listVC {
            list.delegate = self
        }
        loadVCs()
        updateUI()
        manager.addDelegate(self)
        print(plistManager.getAllModuleKeys())
        AppDelegate.setDelegate(aDelegate: self)
        dealWithMenu()
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        isMenuOn = AppDelegate.plistManager.isMenuOn()
        dealWithMenu()
        if let w = NSApp.windows.first,
            let toolbar = w.toolbar,
            let f = toolbar.items.first,
            f.itemIdentifier != .toggleSidebar {
            toolbar.insertItem(withItemIdentifier: .toggleSidebar, at: 0)
        }
    }
    
    @IBAction func textFieldDidEnter(_ sender: NSSearchField) {
        doSearch(with: sender.stringValue)
    }
    
    func toggleMenu() {
        isMenuOn = !isMenuOn
        AppDelegate.plistManager.setMenu(isOn: isMenuOn)
        dealWithMenu()
    }
    
    private func dealWithMenu() {
        if isMenuOn {
            if let list = listVC {
                splitView.insertArrangedSubview(list.view, at: 0)
            }
        } else {
            splitView.removeArrangedSubview(listVC!.view)
        }
        arrangeAllViews()
    }
    
    private func doSearch(with text: String) {
        if text.matches(String.regexForChapter) {
            let m = text.capturedGroups(withRegex: String.regexForChapter)!
            manager.changeChapter(to: Int(m[0])!)
        } else if text.matches(String.regexForBookRefference) {
            let match = text.capturedGroups(withRegex: String.regexForBookRefference)!
            if manager.changeBook(by: match[0]),
                match.count > 1,
                let n = Int(match[1]) {
                manager.changeChapter(to: n)
                if match.count > 2,
                    let verseMatch = text.replacingOccurrences(of: " ", with: "").matches(withRegex: String.regexForVerses),
                    verseMatch[0][0] == match[1] {
                    let v = verseMatch[1...]
                    manager.setVerses(from: v.map {$0[0]})
                }
            }
        } else if text.matches(String.regexForVersesOnly) {
            let verseMatch = text.replacingOccurrences(of: " ", with: "").matches(withRegex: String.regexForVersesOnly)!
            manager.changeChapter(to: Int(verseMatch[0][0])!)
            let v = verseMatch[1...]
            if v.count > 0 {
                manager.setVerses(from: v.map {$0[0]})
            }
        }
        updateUI()
    }
    
    private func loadVCs() {
        for index in 0..<manager.activeModules.count {
            if let newVC = NSStoryboard.main?.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("Module VC")) as? ModuleViewController {
                newVC.moduleManager = manager
                newVC.currentModule = manager.activeModules[index]
                newVC.index = index
                newVC.delegate = self
                newVC.setSplitViewParticipants(displayedModuleControllers)
                displayedModuleControllers.forEach {$0.addSplitViewParticipant(newVC)}
                displayedModuleControllers.append(newVC)
                splitView.addArrangedSubview(newVC.view)
                manager.addDelegate(newVC)
            }
        }
        arrangeAllViews()
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
                newVC.delegate = self
                newVC.setSplitViewParticipants(displayedModuleControllers)
                displayedModuleControllers.forEach {$0.addSplitViewParticipant(newVC)}
                displayedModuleControllers.append(newVC)
                splitView.addArrangedSubview(newVC.view)
                manager.addDelegate(newVC)
            }
        }
        arrangeAllViews()
    }

    private func arrangeAllViews() {
        guard splitView.arrangedSubviews.count > 0 else {return}
        let count = splitView.arrangedSubviews.count
        if isMenuOn {
            let smallAmountOfWindow = splitView.bounds.width / 5.0
            splitView.setPosition(smallAmountOfWindow, ofDividerAt: 0)
            let width = (splitView.bounds.width - smallAmountOfWindow ) / CGFloat(count - 1)
            for i in 1..<count - 1 {
                splitView.setPosition(smallAmountOfWindow + CGFloat(i) * width, ofDividerAt: i)
            }
        } else {
            let width = splitView.bounds.width / CGFloat(count)
            for i in 0..<count - 1 {
                splitView.setPosition(CGFloat(i + 1) * width, ofDividerAt: i)
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
        if parameters.count > 1,
            [StrongId.newTestament, StrongId.oldTestament].contains(parameters[0]) {
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
        } else {
            doSearch(with: parameters[0])
        }
    }
}

enum OpenError: Error {
    case message(String)
    case ok
}

extension MainViewController: SplitViewDelegate {
    func splitViewWouldLikeToResign(being number: Int) {
        splitView.removeArrangedSubview(displayedModuleControllers[number].view)
        displayedModuleControllers.forEach {$0.removeSplitViewParticipant(displayedModuleControllers[number])}
        displayedModuleControllers.remove(at: number)
        manager.removeModule(at: number)
        arrangeAllViews()
    }
}

extension MainViewController: OutlineSelectionDelegate {
    func outlineSelectionViewDidSelect(chapter: Int, book: Int, module: String?) {
        manager.changeBook(to: book)
        manager.changeChapter(to: chapter)
    }
}
