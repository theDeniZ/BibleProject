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
    @IBOutlet weak var searchTextField: UITextField!
    
    
    private var leftTextStorage: NSTextStorage?
    private var rightTextStorage: NSTextStorage?
    private var presentedVC: UIViewController?
    private var draggedScrollView: Int = 0
    
    private var isInSearch: Bool = false {didSet{updateSearchUI()}}
    
    var verseManager = VerseManager()
    var delegate: CenterViewControllerDelegate?
    var overlapped: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        AppDelegate.shared.urlDelegate = self
        loadTextViews()
        leftTextView.delegate = self
        rightTextView.delegate = self
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(named: "menu"),
            style: .plain,
            target: self,
            action: #selector(toggleMenu)
        )
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(named: "search"),
            style: .plain,
            target: self,
            action: #selector(toggleSearch)
        )
        
    }
    
    @IBAction func searchTextFieldDidEnter(_ sender: UITextField) {
        if let text = sender.text {
            doSearch(text: text)
        }
        toggleSearch()
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
            rightTextView.isHidden = false
            rightTextView.attributedText = attributedString
        } else {
            rightTextView.isHidden = true
        }
        rightTextView.contentOffset = CGPoint(0,0)
        leftTextView.contentOffset = CGPoint(0,0)
    }

    @objc private func toggleMenu() {
        delegate?.toggleLeftPanel?()
    }
    
    @objc private func toggleSearch() {
        isInSearch = !isInSearch
    }
    
    private func updateSearchUI() {
        if isInSearch {
            searchTextField.isHidden = false
            if overlapped {
                toggleMenu()
            }
            searchTextField.becomeFirstResponder()
        } else {
            searchTextField.isHidden = true
            searchTextField.text = nil
            view.endEditing(true)
        }
    }
    
    private func doSearch(text: String) {
        if text.matches(String.regexForChapter) {
            let m = text.capturedGroups(withRegex: String.regexForChapter)!
            verseManager.setChapter(number: Int(m[0])!)
        } else if text.matches(String.regexForBookRefference) {
            let match = text.capturedGroups(withRegex: String.regexForBookRefference)!
            if verseManager.setBook(by: match[0]),
                match.count > 1,
                let n = Int(match[1]) {
                verseManager.setChapter(number: n)
                if match.count > 2,
                    let verseMatch = text.replacingOccurrences(of: " ", with: "").matches(withRegex: String.regexForVerses),
                    verseMatch[0][0] == match[1] {
                    let v = verseMatch[1...]
                    verseManager.setVerses(from: v.map {$0[0]})
                }
            }
        } else if text.matches(String.regexForVerses) {
            let verseMatch = text.replacingOccurrences(of: " ", with: "").matches(withRegex: String.regexForVerses)!
            verseManager.setChapter(number: Int(verseMatch[0][0])!)
            let v = verseMatch[1...]
            if v.count > 0 {
                verseManager.setVerses(from: v.map {$0[0]})
            }
        }
        loadTextViews()
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
