//
//  NoteVC.swift
//  macB
//
//  Created by Denis Dobanda on 19.03.19.
//  Copyright © 2019 Denis Dobanda. All rights reserved.
//

import Cocoa

class NoteViewController: NSViewController {
    
    var index = (Int, Int)(0,0)
    var delegate: ModelVerseDelegate?
    
    @IBOutlet var textView: NSTextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.string = delegate?.isThereANote(at: index) ?? ""
    }
    
    @IBAction func removeAction(_ sender: NSButton) {
        delegate?.setNote(at: index, nil)
        dismiss(nil)
    }
    
    @IBAction func saveButton(_ sender: NSButton) {
        delegate?.setNote(at: index, textView.string)
        dismiss(nil)
    }
    
    @IBAction func closeAction(_ sender: Any) {
        dismiss(nil)
    }
}
