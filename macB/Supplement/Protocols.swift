//
//  DownloadProtocol.swift
//  macB
//
//  Created by Denis Dobanda on 21.12.18.
//  Copyright © 2018 Denis Dobanda. All rights reserved.
//

import Foundation

protocol DownloadDelegate {
    func initiateDownload(by key: String, completition: ((Bool) -> Void)?)
    func initiateRemoval(by key: String, completition: ((Bool) -> Void)?)
}

extension DownloadDelegate {
    func initiateDownload(by key: String, completition: ((Bool) -> Void)? = nil) {}
    func initiateRemoval(by key: String, completition: ((Bool) -> Void)? = nil) {}
}

protocol ModelUpdateDelegate {
    var hashValue: Int {get}
    func modelChanged()
}

protocol DragDelegate {
    func dragCompleted(with path: String)
}

protocol DownloadProgressDelegate {
    func downloadStarted(with pendingNumber: Int)
    func downloadCompleted(with success: Bool, at name: String)
    func downloadFinished()
}

protocol StrongsLinkEmbeddable {
    var strongNumbersAvailable: Bool {get}
    func embedStrongs(to link: String, using size: CGFloat, linking: Bool) -> NSAttributedString
}

protocol URLDelegate {
    func openedURL(with parameters: [String])
}

protocol SplitViewDelegate {
    func splitViewWouldLikeToResign(being: Int)
}

protocol SplitViewParticipant {
    var hashValue: Int {get}
    func splitViewParticipantDidEndScrolling()
    func splitViewParticipantDidScrolled(to offsetRatio: CGFloat)
}

protocol SharingSelectingDelegate {
    func sharingObjectWasSelected(with status: Bool, being: Int)
}
