//
//  OutlineCellView.swift
//  macB
//
//  Created by Denis Dobanda on 13.02.19.
//  Copyright © 2019 Denis Dobanda. All rights reserved.
//

import Cocoa

class OutlineCellView: NSTableCellView {
    var title: String? {didSet{updateUI()}}
    
    @IBOutlet weak private var text: NSTextField! {didSet{updateUI()}}
    
    private func updateUI() {
        text?.stringValue = title ?? ""
    }
    
}
