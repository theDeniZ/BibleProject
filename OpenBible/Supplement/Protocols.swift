//
//  ModalDelegate.swift
//  SplitB
//
//  Created by Denis Dobanda on 29.10.18.
//  Copyright © 2018 Denis Dobanda. All rights reserved.
//

import UIKit

@objc
protocol CenterViewControllerDelegate {
    @objc optional func toggleLeftPanel()
    @objc optional func collapseSidePanels()
}

protocol SidePanelViewControllerDelegate {
    func didSelect(chapter: Int, in book: Int)
    func setNeedsReload()
}

protocol TextViewDelegate {
    func textViewDidResize(to size: CGSize)
}

protocol BookTableViewCellDelegate {
    func bookTableViewCellDidSelect(chapter: Int, in book: Int)
}

protocol ModalDelegate {
    func modalViewWillResign()
}

protocol StrongsLinkEmbeddable {
    var strongNumbersAvailable: Bool {get}
    func embedStrongs(to link: String, using size: CGFloat, linking: Bool) -> NSAttributedString
}

protocol URLDelegate {
    func openedURL(with parameters: [String])
}

protocol SharingObjectTableCellDelegate {
    func sharingTableCellWasSelected(_ state: Bool, at index: Int)
}

protocol SyncManagerDelegate {
    func syncManagerDidGetUpdate()
    func syncManagerDidTerminate()
    
    func syncManagerDidStartSync(at: Int)
    func syncManagerDidSync(_ progress: Float)
    func syncManagerDidEndSync(at: Int, with: Bool)
    func syncManagerDidFinished()
}
