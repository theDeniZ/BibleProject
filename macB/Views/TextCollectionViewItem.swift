//
//  TextCollectionViewItem.swift
//  macB
//
//  Created by Denis Dobanda on 17.03.19.
//  Copyright © 2019 Denis Dobanda. All rights reserved.
//

import Cocoa

class TextCollectionViewItem: NSCollectionViewItem {

    var text: NSAttributedString?// {didSet{updateUI()}}
    var index = (Int, Int)(0,0)// {didSet{updateUI()}}
    var delegate: ModelVerseDelegate? {didSet{manageNote()}}
    var presentee: NSViewController!// {didSet{updateUI()}}
    
    @IBOutlet private weak var topMarkImageView: NSButton!// {didSet{manageNote()}}
    @IBOutlet private var mainTextView: ReactTextView!// {didSet{updateUI()}}
    
    private var textStorage: NSTextStorage?
    
    @IBAction func topMarkAction(_ sender: NSButton) {
        let vc = NSStoryboard.main?.instantiateController(withIdentifier: "Note VC") as! NoteViewController
        vc.delegate = delegate
        vc.index = index
        presentee.presentAsSheet(vc)
    }
    
    private func manageNote() {
        topMarkImageView?.isHidden = delegate?.isThereANote(at: index) == nil
    }
    
    override func viewWillAppear() {
        updateUI()
        manageNote()
        super.viewWillAppear()
    }
    
    private func updateUI() {
        mainTextView.verseDelegate = delegate
        mainTextView.presentee = presentee
        mainTextView.index = index
        if let text = text, let lm = mainTextView?.layoutManager {
            textStorage?.removeLayoutManager(lm)
            textStorage = NSTextStorage(attributedString: text)
            textStorage!.addLayoutManager(lm)
            if var c = NSColor(named: NSColor.Name("linkTextColor")) {
                if let colorData = delegate?.isThereAColor(at: index),
                    let color = NSKeyedUnarchiver.unarchiveObject(with: colorData) as? NSColor {
                    c = color.invert()
                }
                mainTextView?.linkTextAttributes = [.foregroundColor: c, .cursor: NSCursor.contextualMenu]
            }
            //            textView?.setSelectedRange(NSMakeRange(textView.string.count, 0))
        }
    }
    
}
