//
//  ModalDelegate.swift
//  SplitB
//
//  Created by Denis Dobanda on 29.10.18.
//  Copyright © 2018 Denis Dobanda. All rights reserved.
//

import UIKit

//protocol ContainingViewController: class {
//    var overlapped: Bool {get set}
//    func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator)
//}

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

@objc
protocol ConsistencyManagerDelegate {
    var hash: Int {get}
    @objc optional func consistentManagerDidChangedModel()
    @objc optional func consistentManagerDidStartUpdate()
    @objc optional func consistentManagerDidUpdatedProgress(to: Double)
    @objc optional func consistentManagerDidEndUpdate()
}

protocol SearchManagerDelegate {
    func searchManagerDidGetUpdate(results: [SearchResult]?)
    func searchManagerDidGetError(error: Error)
}

protocol ModelVerseDelegate {
    func isThereANote(at: (module: Int, verse: Int)) -> String?
    func setNote(at: (module: Int, verse: Int), _ note: String?)
    func isThereAColor(at: (module: Int, verse: Int)) -> Data?
    func setColor(at: (module: Int, verse: Int), _ color: Data?)
}

protocol UIPresentee {
    func presentNote(at index: (Int, Int))
    func presentMenu(at index: (Int, Int))
}

protocol UIResignDelegate {
    func viewControllerWillResign()
}
