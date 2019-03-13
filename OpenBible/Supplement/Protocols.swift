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
}

protocol ContainingViewController: class, SidePanelViewControllerDelegate {
    var delegate: CenterViewControllerDelegate? {get set}
    var overlapped: Bool {get set}
    func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator)
}

protocol BookTableViewCellDelegate {
    func bookTableViewCellDidSelect(chapter: Int, in book: Int)
}

protocol ModalDelegate {
    func modalViewWillResign()
}

protocol ManagerDelegate {
    func managerDidUpdate()
}

protocol StrongsLinkEmbeddable {
    var strongNumbersAvailable: Bool {get}
    func embedStrongs(to link: String, using size: CGFloat, linking: Bool) -> NSAttributedString
}

protocol URLDelegate {
    func openedURL(with parameters: [String])
}

@objc
protocol ConsistencyManagerDelegate {
    var hashValue: Int {get}
    @objc optional func consistentManagerDidChangedModel()
    @objc optional func consistentManagerDidStartUpdate()
    @objc optional func consistentManagerDidUpdatedProgress(to: Double)
    @objc optional func consistentManagerDidEndUpdate()
}

protocol SearchManagerDelegate {
    func searchManagerDidGetUpdate(results: [SearchResult]?)
    func searchManagerDidGetError(error: Error)
}
