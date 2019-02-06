//
//  SplitTextViewController.swift
//  OpenBible
//
//  Created by Denis Dobanda on 06.02.19.
//  Copyright © 2019 Denis Dobanda. All rights reserved.
//

import UIKit

class SplitTextViewController: UIViewController {

    @IBOutlet weak var leftTextView: UITextView!
    @IBOutlet weak var rightTextView: UITextView!
    
    private var leftTextStorage: NSTextStorage?
    private var rightTextStorage: NSTextStorage?
    private var presentedVC: UIViewController?
    private var draggedScrollView: Int = 0
    
    var verseManager = VerseManager()
    var delegate: CenterViewControllerDelegate?
    var overlapped: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        AppDelegate.shared.urlDelegate = self
        loadTextViews()
        leftTextView.delegate = self
        rightTextView.delegate = self
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "menu"), style: .plain, target: self, action: #selector(toggleMenu))
    }
    
    func loadTextViews() {
        navigationItem.title = "\(verseManager.get1BookName()) \(verseManager.chapterNumber)"
        let verses = verseManager.getVerses()
        let attributedString = verses.0.reduce(NSMutableAttributedString()) { (r, each) -> NSMutableAttributedString in
            r.append(each)
            return r
        }
        leftTextView.attributedText = attributedString
        if let second = verses.1 {
            let attributedString = second.reduce(NSMutableAttributedString()) { (r, each) -> NSMutableAttributedString in
                r.append(each)
                return r
            }
            rightTextView.attributedText = attributedString
        }
        rightTextView.contentOffset = CGPoint(0,0)
        leftTextView.contentOffset = CGPoint(0,0)
    }

    @objc private func toggleMenu() {
        delegate?.toggleLeftPanel?()
    }
}

extension SplitTextViewController: UITextViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let textView = scrollView as? UITextView {
            switch draggedScrollView {
            case 1:
                rightTextView.contentOffset.y = (textView.contentOffset.y / textView.contentSize.height ) * rightTextView.contentSize.height
            case 2:
                leftTextView.contentOffset.y = (textView.contentOffset.y / textView.contentSize.height ) * leftTextView.contentSize.height
            default:break
            }
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if let textView = scrollView as? UITextView {
            if textView == leftTextView {
                draggedScrollView = 1
            } else if textView == rightTextView {
                draggedScrollView = 2
            }
        }
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        draggedScrollView = 0
    }
}

extension SplitTextViewController: URLDelegate {
    func openedURL(with parameters: [String]) {
        if parameters.count > 1 {
            switch parameters[0] {
            case "Hebrew", "Greek":
                let vc = UIStoryboard.main().instantiateViewController(withIdentifier: "StrongVC") as! StrongViewController
                vc.identifier = parameters[0]
                vc.numbers = parameters[1].split(separator: "+").map {Int(String($0))!}
                if let nav = navigationController {
                    nav.pushViewController(vc, animated: true)
                } else {
                    present(vc, animated: true, completion: nil)
                }
                presentedVC = vc
            default: break
            }
        } else {
//            parseSearch(text: parameters[0])
        }
    }
}


extension SplitTextViewController: SidePanelViewControllerDelegate {
    func didSelect(chapter: Int, in book: Int) {
        delegate?.collapseSidePanels?()
        verseManager.chapterNumber = chapter
        verseManager.bookNumber = book
        loadTextViews()
    }
    
    func setNeedsReload() {
        loadTextViews()
    }
    
}
