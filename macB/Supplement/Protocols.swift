//
//  DownloadProtocol.swift
//  macB
//
//  Created by Denis Dobanda on 21.12.18.
//  Copyright © 2018 Denis Dobanda. All rights reserved.
//

import Foundation

protocol ModelUpdateDelegate {
    var hashValue: Int {get}
    func modelChanged(_ fully: Bool)
}

protocol DragDelegate {
    func dragCompleted(with path: String)
}

protocol DownloadProgressDelegate {
    func downloadStarted(with pendingNumber: Int)
    func downloadCompleted(with success: Bool, at name: String)
    func downloadFinished()
}

protocol DownloadDelegate {
    func download(index: (Int, Int), completition: ((Bool) -> ())?)
    func remove(index: (Int, Int), completition: ((Bool) -> ())?)
}

protocol StrongsLinkEmbeddable {
    var strongNumbersAvailable: Bool {get}
    func embedStrongs(to link: String, using size: CGFloat, linking: Bool, withTooltip: Bool) -> NSAttributedString
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

protocol SideMenuDelegate {
    func sideMenuDidSelect(index: SpiritIndex)
}

protocol OutlineSelectionDelegate {
    func outlineSelectionViewDidSelect(chapter: Int, book: Int, module: String?)
}

protocol SearchManagerDelegate {
    func searchManagerDidGetUpdate(results: [SearchResult]?)
    func searchManagerDidGetError(error: Error)
}
