//
//  SharingTCV.swift
//  macB
//
//  Created by Denis Dobanda on 11.01.19.
//  Copyright © 2019 Denis Dobanda. All rights reserved.
//

import Cocoa

class SharingTCV: NSTableCellView {
    
    var checked: Bool = true {didSet{updateUI()}}
    var title: String = "" {didSet{updateUI()}}
    var index: Int = 0
    var delegate: SharingSelectingDelegate?
    
    @IBOutlet private weak var check: NSButton! {didSet{updateUI()}}
    
    private func updateUI() {
        check?.title = title
        check?.state = checked ? .on : .off
    }
    
    @IBAction func checked(_ sender: NSButton) {
        delegate?.sharingObjectWasSelected(with: sender.state == .on, being: index)
    }
    
}
