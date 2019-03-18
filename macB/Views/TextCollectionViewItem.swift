//
//  TextCollectionViewItem.swift
//  macB
//
//  Created by Denis Dobanda on 17.03.19.
//  Copyright © 2019 Denis Dobanda. All rights reserved.
//

import Cocoa

class TextCollectionViewItem: NSCollectionViewItem {

    var text: NSAttributedString? {didSet{updateUI()}}
    var index = (Int, Int)(0,0)
    var delegate: ModelVerseDelegate? {didSet{manageNote()}}
    
    @IBOutlet private weak var topMarkImageView: NSButton! {didSet{manageNote()}}
    @IBOutlet private var mainTextView: ReactTextView! {didSet{updateUI()}}
    
    private var textStorage: NSTextStorage?
    private var noteText: String?
    
    @IBAction func topMarkAction(_ sender: NSButton) {
        print(noteText!)
    }
    
    private func manageNote() {
        noteText = delegate?.isThereANote(at: index)
        topMarkImageView?.isHidden = noteText == nil
    }
    
    private func updateUI() {
        if let text = text, let lm = mainTextView?.layoutManager {
            textStorage?.removeLayoutManager(lm)
            textStorage = NSTextStorage(attributedString: text)
            textStorage!.addLayoutManager(lm)
            if let c = NSColor(named: NSColor.Name("linkTextColor")) {
                mainTextView?.linkTextAttributes = [.foregroundColor: c, .cursor: NSCursor.contextualMenu]
            }
            //            textView?.setSelectedRange(NSMakeRange(textView.string.count, 0))
        }
        mainTextView.verseDelegate = delegate
    }
    
}
