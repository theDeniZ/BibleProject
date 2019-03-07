//
//  DownloadCellView.swift
//  macB
//
//  Created by Denis Dobanda on 07.03.19.
//  Copyright © 2019 Denis Dobanda. All rights reserved.
//

import Cocoa

class DownloadCellView: NSTableCellView {
    
    var index: (Int, Int) = (0,0)
    var left: String? {didSet{updateUI()}}
    var right: String? {didSet{updateUI()}}
    var isLoaded: Bool = false {didSet{updateUI()}}
    var loading: Bool = false {didSet{updateUI()}}
    var delegate: DownloadDelegate?
    
    @IBOutlet private weak var leftLabel: NSTextField! {didSet{updateUI()}}
    @IBOutlet private weak var rightLabel: NSTextField! {didSet{updateUI()}}
    
    @IBOutlet private weak var progress: NSProgressIndicator! {didSet{updateUI()}}
    @IBOutlet private weak var actionButton: NSButton! {didSet{updateUI()}}
    
    private func updateUI() {
        leftLabel?.stringValue = left ?? ""
        rightLabel?.stringValue = right ?? ""
        actionButton?.title = isLoaded ? "Remove" : "Download"
        progress?.isHidden = !loading
        actionButton?.isHidden = loading
        if loading {
            progress?.startAnimation(nil)
        } else {
            progress?.stopAnimation(nil)
        }
    }
    
    @IBAction func buttonPressed(_ sender: NSButton) {
        loading = true
        updateUI()
        if isLoaded {
            delegate?.remove(index: index) { (success) in
                DispatchQueue.main.async {
                    self.isLoaded = !success
                    self.loading = false
                }
            }
        } else {
            delegate?.download(index: index) { (success) in
                DispatchQueue.main.async {
                    self.isLoaded = success
                    self.loading = false
                }
            }
        }
    }
    
}
