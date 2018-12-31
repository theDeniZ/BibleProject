//
//  LabelCellView.swift
//  macB
//
//  Created by Denis Dobanda on 30.12.18.
//  Copyright © 2018 Denis Dobanda. All rights reserved.
//

import Cocoa

class LabelCellView: NSTableCellView {
    
    var text: String? {didSet{updateUI()}}
    
    @IBOutlet weak var label: NSTextField! {didSet{updateUI()}}
    
    private func updateUI() {
        label?.stringValue = text ?? ""
        label?.maximumNumberOfLines = 0
    }
    
}
