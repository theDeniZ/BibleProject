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
    
    @IBOutlet private weak var comboBook: NSComboBox!
    @IBOutlet private weak var comboChapter: NSComboBox!
    @IBOutlet private weak var searchField: NSSearchField!
    @IBOutlet private var textView: NSTextView!
    
    private var books: [String] = []
    private var textStorage: NSTextStorage?
    
    @IBAction func bookSelected(_ sender: NSComboBox) {
        if sender.indexOfSelectedItem < books.count, sender.indexOfSelectedItem >= 0 {
            index = manager.set(book: books[sender.indexOfSelectedItem], at: index)
            loadChapters()
        }
        loadUI()
    }
    
    @IBAction func chapterSelected(_ sender: NSComboBox) {
        manager.setChapter(number: sender.indexOfSelectedItem, at: index)
        updateUI()
    }
    @IBAction func didSearch(_ sender: NSSearchField) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadUI()
        if let (book, selected) = manager.readyToDisplay(at: index) {
            loadChapters()
            comboChapter.selectItem(at: selected)
            if let bookIndex = books.firstIndex(of: book) {
                comboBook.selectItem(at: bookIndex)
            }
            updateUI()
        }
    }
    
    private func loadUI() {
        if let books = manager.getAvailableBooks() {
            self.books = books
            comboBook?.removeAllItems()
            comboBook?.addItems(withObjectValues: books)
        }
    }
    
    private func updateUI() {
        let textArray = manager[index]
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
    
    private func loadChapters() {
        if let chapters = manager.getAvailableChapters(index: index) {
            comboChapter?.removeAllItems()
            comboChapter?.addItems(withObjectValues: chapters)
        }
    }
    
}
