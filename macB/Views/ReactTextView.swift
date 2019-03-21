//
//  ReactTextView.swift
//  macB
//
//  Created by Denis Dobanda on 18.03.19.
//  Copyright © 2019 Denis Dobanda. All rights reserved.
//

import Cocoa

class ReactTextView: NSTextView {
    
    var verseDelegate: ModelVerseDelegate?
    var index: (Int, Int) = (0,0)
    var presentee: NSViewController!
    
    lazy var contextMenu: NSMenu = {
        let rightClickMenu = NSMenu()
        rightClickMenu.addItem(withTitle: "Add note", action: #selector(addNoteAction), keyEquivalent: "")
        let nib = NSNib(nibNamed: "ColorPickerView", bundle: nil)
        var array: NSArray? = NSArray()
        if let n = nib, n.instantiate(withOwner: self, topLevelObjects: &array), let ar = array {
            var cp: ColorPickerView? = nil
            for v in ar {
                if let view = v as? ColorPickerView {
                    cp = view
                    break
                }
            }
            if let picker = cp {
                let menuItem = NSMenuItem()
                picker.delegate = verseDelegate
                picker.index = index
                menuItem.view = picker
                rightClickMenu.addItem(menuItem)
            }
        }
        return rightClickMenu
    }()
    
    @objc private func addNoteAction() {
        let vc = NSStoryboard.main?.instantiateController(withIdentifier: "Note VC") as! NoteViewController
        vc.delegate = verseDelegate
        vc.index = index
        presentee.presentAsSheet(vc)
    }
    
    @objc private func clearColor() {
        verseDelegate?.setColor(at: index, nil)
    }
    
    override func rightMouseDown(with event: NSEvent) {
        NSMenu.popUpContextMenu(contextMenu, with: event, for: self)
    }
}
