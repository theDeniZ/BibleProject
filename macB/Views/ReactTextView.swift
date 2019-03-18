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
    
    lazy var contextMenu: NSMenu = {
        let rightClickMenu = NSMenu()
        rightClickMenu.addItem(withTitle: "Add card", action: #selector(doSome), keyEquivalent: "")
        rightClickMenu.addItem(withTitle: "Remove card", action: #selector(doSome), keyEquivalent: "")
        return rightClickMenu
    }()
    
    @objc private func doSome() {
        print("Did some")
    }
    
    override func rightMouseDown(with event: NSEvent) {
        NSMenu.popUpContextMenu(contextMenu, with: event, for: self)
    }
}
