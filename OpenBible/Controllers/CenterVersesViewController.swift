//
//  CenterVersesViewController.swift
//  SplitB
//
//  Created by Denis Dobanda on 22.11.18.
//  Copyright © 2018 Denis Dobanda. All rights reserved.
//

import UIKit

class CenterVersesViewController: CenterViewController {
    
    var verseTextManager: VerseTextManager?
    var verseManager: VerseManager?
    var verseTextView: VerseTextView! { didSet{ verseTextView?.delegate = self }}
    
    override var customTextView: CustomTextView! {
        get {return verseTextView}
        set {print ( "Error: set customTextView")}
    }
    override var coreManager: Manager? {
        get {
            return verseManager
        }
        set {
            print("Error!! didSet coreManager")
        }
    }
    override var textManager: TextManager? {
        get {
            return verseTextManager
        }
        set {
            print("Error!! didSet textManager")
        }
    }
    
    @IBOutlet weak var search: SearchTextField!
    private var isInSearch = false {
        didSet {
            topScrollConstraint.constant = isInSearch ? search.frame.height : 0.0
            if isInSearch {
                search.isHidden = false
                search.text = nil
                search.becomeFirstResponder()
            } else {
                search.resignFirstResponder()
                search.isHidden = true
                search.text = nil
                view.endEditing(true)
            }
        }
    }
    @IBOutlet weak var topScrollConstraint: NSLayoutConstraint!
    
    @IBAction func searchAction(_ sender: UIBarButtonItem) {
        isInSearch = !isInSearch
    }
    
    private var tapInProgress = false
    private var panInProgress = false
    private var menuRect: CGRect?
    private var firstMenuRect: CGRect?
    private var timerScrollingMenu: Timer?
    
    private weak var presentedVC: UIViewController?
    
    @IBAction func searchDidEnd(_ sender: SearchTextField) {
        if let text = sender.text {
            parseSearch(text: text)
        }
        isInSearch = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        AppDelegate.shared.urlDelegate = self
        
        if let titles = verseManager?.getBooksTitles() {
            search.filterStrings(titles)
        }
        search.theme.font = UIFont.systemFont(ofSize: 12)
        search.theme.bgColor = UIColor (red: 0.9, green: 0.9, blue: 0.9, alpha: 0.9)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(touch(sender: )))
        tap.numberOfTapsRequired = 2
        tap.numberOfTouchesRequired = 1
        scrollView.addGestureRecognizer(tap)
        
        let tapLink = UITapGestureRecognizer(target: self, action: #selector(touchLink(sender: )))
        tapLink.numberOfTapsRequired = 1
        tapLink.numberOfTouchesRequired = 1
        scrollView.addGestureRecognizer(tapLink)
        
        
//        Strong.printStats()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        Strong.printStats()
    }
    
    override func loadTextManager(_ forced: Bool = true) {
        //        var first: [String] = []
        //        var second: [String] = []
        //        let texts = verseTextManager?.getTwoStrings()
        //        if let f = texts?.0 {
        //            first = f
        //        }
        //        if let s = texts?.1 {
        //            second = s
        //        }
        if forced, let verses = verseManager?.getVerses() {
            verseTextManager = VerseTextManager(verses: verses)
            if let m = coreManager {
                navigationItem.title = "\(m.get1BookName()) \(m.chapterNumber)"
            }
            
            switch verseTextView {
            case .some:
                verseTextView.removeFromSuperview()
            default:break
            }
            
            verseTextView = VerseTextView(frame: scrollView.bounds)
            verseTextView.verseTextManager = verseTextManager
            scrollView.addSubview(verseTextView)
            scrollView.scrollRectToVisible(CGRect(0, 0, 1, 1), animated:false)
        }
        textManager?.fontSize = fontSize
        customTextView.setNeedsLayout()
    }
    
    @objc private func touch(sender: UITapGestureRecognizer) {
        if sender.state == .ended && !panInProgress {
            if !overlapped, let rect = verseTextView.selectVerse(at: sender.location(in: scrollView)) {
                tapInProgress = true

                switch firstMenuRect {
                case .none:
                    menuRect = rect
                    firstMenuRect = rect
                case .some(let r):
                    menuRect = CGRect(bounding: r, with: rect)
                    menuRect!.size.width = scrollView.bounds.width
                }
                showMenu()
            }
        }
        isInSearch = false
        delegate?.collapseSidePanels?()
        overlapped = false
        panInProgress = false
    }
    
    @objc private func touchLink(sender: UITapGestureRecognizer) {
        let link = verseTextView.getSelectionLink(at: sender.location(in: verseTextView))
        print(link)
        if let text = link {
            let start = text.index(text.startIndex, offsetBy: AppDelegate.URLServerRoot.count)
            openedURL(with: text[start...].split(separator: "/").map{String($0)})
        }
    }
    
    private func showMenu() {
        isInSearch = false
        if let s = customTextView.getSelection(), let rect = menuRect {
            textToCopy = s
            becomeFirstResponder()
            let copyItem = UIMenuItem(title: "Copy".localized, action: #selector(copySelector))
            let defineItem = UIMenuItem(title: "Define".localized, action: #selector(defineSelector))
            UIMenuController.shared.menuItems = [copyItem, defineItem]
            UIMenuController.shared.setTargetRect(rect, in: scrollView)
            UIMenuController.shared.setMenuVisible(true, animated: true)
        } else {
            tapInProgress = false
            panInProgress = false
            menuRect = nil
            firstMenuRect = nil
        }
    }
    
    private func parseSearch(text: String) {
        if text.matches(String.regexForChapter) {
            let m = text.capturedGroups(withRegex: String.regexForChapter)!
            verseManager?.setChapter(number: Int(m[0])!)
        } else if text.matches(String.regexForBookRefference) {
            let match = text.capturedGroups(withRegex: String.regexForBookRefference)!
            if let b = verseManager?.setBook(by: match[0]), b,
                match.count > 1,
                let n = Int(match[1]) {
                verseManager?.setChapter(number: n)
                if match.count > 2,
                    let verseMatch = text.replacingOccurrences(of: " ", with: "").matches(withRegex: String.regexForVerses),
                    verseMatch[0][0] == match[1] {
                    let v = verseMatch[1...]
                    verseManager?.setVerses(from: v.map {$0[0]})
                }
            }
        } else if text.matches(String.regexForVerses) {
            let verseMatch = text.replacingOccurrences(of: " ", with: "").matches(withRegex: String.regexForVerses)!
            verseManager?.setChapter(number: Int(verseMatch[0][0])!)
            let v = verseMatch[1...]
            if v.count > 0 {
                verseManager?.setVerses(from: v.map {$0[0]})
            }
        }
        loadTextManager()
    }
    
    //    private func parseSearch(text: String) {
    //        guard text.count > 0,
    //            let matched = text.capturedGroups(withRegex: String.regexForBookRefference)
    //            else {return}
    //        let book = matched[0]
    //        _ = verseManager?.setBook(byTitle: book)
    //
    //        if matched.count > 1, let number = Int(matched[1]) {
    //            verseManager?.setChapter(number: number)
    //        }
    //        loadTextManager()
    //        if matched.count > 2 {
    //            verseTextView.executeRightAfterDrawingOnce = {
    //                if let v = Int(matched[2]), let rect = self.verseTextView.getRectOf(v) {
    //                    var r = rect
    //                    r.size.height = self.scrollView.bounds.height
    //                    let o = self.scrollView.convert(r.origin, from: self.verseTextView)
    //                    self.scrollView.setContentOffset(o, animated: true)
    //                    if matched.count > 3,
    //                        let last = matched.last,
    //                        let lastVerse = Int(last) {
    //                        self.verseTextView.highlight(v, throught: lastVerse)
    //                    }else {
    //                        self.verseTextView.highlight(v)
    //                    }
    //                }
    //            }
    //        }
    //    }
    
    //    private func highlight(_ rect: CGRect) {
    //        var r = rect
    //        r.size.width = scrollView.bounds.width
    //        let newView = UIView(frame: r)
    //        newView.backgroundColor = UIColor.yellow.withAlphaComponent(0.4)
    //        scrollView.addSubview(newView)
    //        UIView.animate(withDuration: 1.0, delay: 1, animations: {
    //            newView.layer.opacity = 0
    //        }) { (_) in
    //            newView.removeFromSuperview()
    //        }
    //
    //    }
    
    override func scaled(sender: UIPinchGestureRecognizer) {
        isInSearch = false
        fontSize *= sqrt(sender.scale)
        sender.scale = 1.0
        loadTextManager(true)
    }
    
    override func UIMenuControllerWillHide() {
        if !tapInProgress {
            verseTextView.clearSelection()
        }
    }
    
    override func longTap(sender: UILongPressGestureRecognizer) {
        super.longTap(sender: sender)
        panInProgress = true
        tapInProgress = false
        menuRect = nil
        isInSearch = false
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        super.scrollViewDidScroll(scrollView)
        timerScrollingMenu?.invalidate()
        timerScrollingMenu = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { [weak self] (t) in
            self?.showMenu()
            self?.timerScrollingMenu = nil
            t.invalidate()
        }
    }
    
    override func toggleLeftMenu() {
        if isInSearch {
            isInSearch = false
        }
        super.toggleLeftMenu()
    }
}


extension CenterVersesViewController: URLDelegate {
    func openedURL(with parameters: [String]) {
        if parameters.count > 1 {
            switch parameters[0] {
            case "Hebrew", "Greek":
                let vc = UIStoryboard.main().instantiateViewController(withIdentifier: "StrongVC") as! StrongViewController
                vc.identifier = parameters[0]
                vc.numbers = parameters[1].split(separator: "+").map {Int(String($0))!}
                present(vc, animated: true, completion: nil)
                presentedVC = vc
            default: break
            }
        } else {
            parseSearch(text: parameters[0])
        }
    }
}
