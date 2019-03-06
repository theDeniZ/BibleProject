//
//  SearchTableCellView.swift
//  macB
//
//  Created by Denis Dobanda on 06.03.19.
//  Copyright © 2019 Denis Dobanda. All rights reserved.
//

import Cocoa

class SearchTableCellView: NSTableCellView {

    var leftText: String? { didSet { updateUI() } }
    var rightText: String? { didSet { updateUI() } }
    
    @IBOutlet private weak var leftLabel: NSTextField! { didSet { updateUI() } }
    @IBOutlet private weak var rightLabel: NSTextField! { didSet { updateUI() } }
    
    private func updateUI() {
        leftLabel?.stringValue = leftText ?? ""
        rightLabel?.stringValue = rightText ?? ""
    }
    
}
