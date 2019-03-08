//
//  ModuleViewController.swift
//  macB
//
//  Created by Denis Dobanda on 23.12.18.
//  Copyright © 2018 Denis Dobanda. All rights reserved.
//

import Cocoa

class ModuleViewController: NSViewController {

    var moduleManager: CoreManager { return AppDelegate.coreManager }
    var currentModule: Module!
    var index: Int!
    var delegate: SplitViewDelegate?
    
    private var scrollDelegates: [SplitViewParticipant]?
    private var scrollViewIsOccupied = false
    private var textStorage: NSTextStorage?
    private var choise: [String] = []
    private var contentOffset: CGFloat {
        let docView = scrollView.documentView!.bounds.height
        let content = scrollView.contentSize.height
        guard docView - content != 0 else {return 1.0}
        return scrollView.documentVisibleRect.origin.y / (docView - content)
    }
    private var updateTimer: Timer?
    
    @IBOutlet private var textView: NSTextView!
    @IBOutlet private weak var modulePicker: NSComboBox!
    @IBOutlet private weak var scrollView: NSScrollView!
    @IBOutlet weak var closeButton: NSButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(scrollViewDidScroll),
            name: NSScrollView.didLiveScrollNotification,
            object: scrollView
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(scrollViewDidEndScrolling(_:)),
            name: NSScrollView.didEndLiveScrollNotification,
            object: scrollView
        )
        scrollView.verticalScroller?.isHidden = true
        moduleManager.addDelegate(self)
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        updateUI()
    }
    
    private func updateCombo() {
        modulePicker?.removeAllItems()
        modulePicker?.addItem(withObjectValue: currentModule.key ?? currentModule.name ?? "Bible")
        let keys = moduleManager.getAllAvailableModulesKey()
        modulePicker?.addItems(withObjectValues: keys)
        choise = keys
        
        modulePicker?.selectItem(at: 0)
    }
    
    private func updateUI() {
        if index == 0 {
            closeButton.isHidden = true
        }
        updateCombo()
        guard let index = index else {return}
        if index >= moduleManager.modules.count {
            delegate?.splitViewWouldLikeToResign(being: index)
        }
        let strings: [NSAttributedString] = moduleManager[index]
        
        let attributedString = strings.reduce(NSMutableAttributedString()) { (res, each) -> NSMutableAttributedString in
            res.append(each)
            return res
        }
        if let lm = textView?.layoutManager {
            textStorage?.removeLayoutManager(lm)
            textStorage = NSTextStorage(attributedString: attributedString)
            textStorage!.addLayoutManager(lm)
            if let c = NSColor(named: NSColor.Name("linkTextColor")) {
                textView?.linkTextAttributes = [.foregroundColor: c, .cursor: NSCursor.contextualMenu]
            }
//            textView?.setSelectedRange(NSMakeRange(textView.string.count, 0))
        }
        if AppDelegate.plistManager.isTooltipOn {
            loadTooltip()
        }
    }
    
    private func loadTooltip() {
        guard let index = index else {return}
        DispatchQueue.global(qos: .background).async {
            self.updateTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) {
                (_) in
                let strings = self.moduleManager.getAttributedString(from: index, loadingTooltip: true)
                let attributedString = strings.reduce(NSMutableAttributedString()) { (r, each) -> NSMutableAttributedString in
                    r.append(each)
                    return r
                }
                DispatchQueue.main.async {
                    if let lm = self.textView?.layoutManager {
                        self.textStorage = NSTextStorage(attributedString: attributedString)
                        self.textStorage!.addLayoutManager(lm)
                    }
                    self.updateTimer = nil
                }
            }
            self.updateTimer?.fire()
        }
    }
    
    @IBAction func comboPicked(_ sender: NSComboBox) {
        if sender.indexOfSelectedItem > 0 {
            if let m = moduleManager.setActive(choise[sender.indexOfSelectedItem - 1], at: index) {
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
    
    @objc func scrollViewDidScroll(_ notification: Notification) {
//        print(notification)
        scrollView.verticalScroller?.isHidden = true
        if !scrollViewIsOccupied {
//            scrollView.verticalScroller?.isHidden = false
            broadcastChanges()
        }
    }
    
    @objc func scrollViewDidEndScrolling(_ notification: Notification) {
        if !scrollViewIsOccupied {
            broadcastEnding()
        }
    }
}


extension ModuleViewController: ModelUpdateDelegate {
    func modelChanged(_ fully: Bool = false) {
        DispatchQueue.main.async { [weak self] in
            self?.updateUI()
        }
    }
}

extension ModuleViewController: SplitViewParticipant {
    func broadcastChanges() {
        scrollDelegates?.forEach {$0.splitViewParticipantDidScrolled(to: contentOffset)}
    }
    func broadcastEnding() {
        scrollDelegates?.forEach {$0.splitViewParticipantDidEndScrolling()}
    }
    func splitViewParticipantDidScrolled(to offsetRatio: CGFloat) {
        scrollViewIsOccupied = true
        var rect = scrollView.documentVisibleRect
        rect.origin.y = (scrollView.documentView!.bounds.height - rect.height) * offsetRatio
//        rect.origin.y = scrollView.conte * offsetRatio
        scrollView.contentView.scrollToVisible(rect)
        scrollView.verticalScroller?.isHidden = true
//        scrollView.scroll(rect.origin)
        
    }
    func splitViewParticipantDidEndScrolling() {
        scrollViewIsOccupied = false
//        scrollView.verticalScroller?.isHidden = false
//        scrollView.verticalScroller?.drawKnobSlot(in: scrollView.verticalScroller!.rect(for: .knob), highlight: false)
    }
    func addSplitViewParticipant(_ delegate: SplitViewParticipant) {
        if scrollDelegates == nil {
            scrollDelegates = [delegate]
            return
        }
        scrollDelegates?.append(delegate)
    }
    func removeSplitViewParticipant(_ delegate: SplitViewParticipant) {
        scrollDelegates?.removeAll {$0.hashValue == delegate.hashValue}
        if scrollDelegates?.count == 0 {
            scrollDelegates = nil
        }
    }
    func setSplitViewParticipants(_ delegates: [SplitViewParticipant]?) {
        scrollDelegates = delegates
    }
}
