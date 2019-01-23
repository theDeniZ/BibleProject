//
//  DownloadCellView.swift
//  macB
//
//  Created by Denis Dobanda on 21.12.18.
//  Copyright © 2018 Denis Dobanda. All rights reserved.
//

import Cocoa

enum DownloadButtonStrings: String {
    case downloaded = "Remove"
    case notDownloaded = "Download"
}

class DownloadCellView: NSTableCellView {

    var left: String? { didSet {updateUI()}}
    var right: String? { didSet {updateUI()}}
    var loaded: Bool = false { didSet {updateUI()}}
    var loading: Bool = false { didSet {updateUI()}}
    var index: Int = 0 
    
    var delegate: DownloadDelegate?
    
    @IBOutlet private weak var leftLabel: NSTextField! { didSet {updateUI()}}
    @IBOutlet private weak var rightLabel: NSTextField! { didSet {updateUI()}}
    @IBOutlet private weak var button: NSButton! { didSet {updateUI()}}
    @IBOutlet private weak var activityindicator: NSProgressIndicator! { didSet {updateUI()}}
    
    func updateUI() {
        leftLabel?.stringValue = left ?? ""
        rightLabel?.stringValue = right ?? ""
        button?.title = loaded ? DownloadButtonStrings.downloaded.rawValue : DownloadButtonStrings.notDownloaded.rawValue
        if loading {
            button?.isHidden = true
            activityindicator?.isHidden = false
            activityindicator?.startAnimation(nil)
        } else {
            button?.isHidden = false
            activityindicator?.isHidden = true
            activityindicator?.stopAnimation(nil)
        }
    }
    
//    override func draw(_ dirtyRect: NSRect) {
//        super.draw(dirtyRect)
//
//        // Drawing code here.
//    }
//
    @IBAction func buttonTouched(_ sender: NSButton) {
        if let key = left {
            activityindicator.startAnimation(nil)
            activityindicator.isHidden = false
            button.isHidden = true
            if loaded {
                delegate?.initiateRemoval(by: index) { [weak self] (done) in
                    DispatchQueue.main.async { [weak self] in
                        self?.activityindicator.stopAnimation(nil)
                        self?.activityindicator.isHidden = true
                        self?.button.isHidden = false
                        self?.loaded = !done
                        self?.button.title = !done ? DownloadButtonStrings.downloaded.rawValue : DownloadButtonStrings.notDownloaded.rawValue
                    }
                }
            } else {
                delegate?.initiateDownload(by: key) { [weak self] (done) in
                    DispatchQueue.main.async { [weak self] in
                        self?.activityindicator.stopAnimation(nil)
                        self?.activityindicator.isHidden = true
                        self?.button.isHidden = false
                        self?.loaded = done
                        self?.button.title = done ? DownloadButtonStrings.downloaded.rawValue : DownloadButtonStrings.notDownloaded.rawValue
                    }
                }
            }
        }
    }
}
