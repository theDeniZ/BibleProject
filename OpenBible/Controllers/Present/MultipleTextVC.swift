//
//  MultipleTextVC.swift
//  OpenBible
//
//  Created by Denis Dobanda on 11.03.19.
//  Copyright © 2019 Denis Dobanda. All rights reserved.
//

import UIKit

class MultipleTextVC: UIViewController, ContainingViewController {
    
    var verseManager = AppDelegate.coreManager
    var delegate: CenterViewControllerDelegate?
    var overlapped: Bool = false
    
    // MARK: Private implementation
    
    
    @IBOutlet weak var mainCollectionView: UICollectionView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var progressView: ProgressView!
    @IBOutlet weak var mainStackView: UIStackView!
    
    @IBOutlet weak var navigationItemTitleTextField: UITextField!
    
    
    private var leftTextStorage: NSTextStorage?
    private var rightTextStorage: NSTextStorage?
    private var presentedVC: UIViewController?
    private var draggedScrollView: Int = 0
    private var executeOnAppear: (() -> ())?
    
    private var textToPresent = [[NSAttributedString]]()
    private var layoutManager = CVLayoutManager()
    
    private var isInSearch: Bool = false {didSet{updateSearchUI()}}
    
    // MARK: - Actions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mainStackView.spacing = 0
        progressView.isHidden = true
        AppDelegate.shared.consistentManager.addDelegate(self)
        AppDelegate.shared.urlDelegate = self
        loadTextViews()
//        leftTextView.delegate = self
//        rightTextView.delegate = self
        mainCollectionView.dataSource = self
        mainCollectionView.delegate = self
        verseManager.addDelegate(self)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(named: "menu"), style: .plain,
            target: self, action: #selector(toggleMenu)
        )
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(named: "search"), style: .plain,
            target: self, action: #selector(toggleSearch)
        )
        addGestures()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        executeOnAppear?()
    }
    
    private func addGestures() {
        let left = UISwipeGestureRecognizer(target: self, action: #selector(swipeLeft))
        let right = UISwipeGestureRecognizer(target: self, action: #selector(swipeRight))
        left.direction = .left
        right.direction = .right
        view.addGestureRecognizer(left)
        view.addGestureRecognizer(right)
        
        let pan = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(edgePan(_:)))
        pan.edges = .left
        view.addGestureRecognizer(pan)
    }
    
    @IBAction func searchTextFieldDidEnter(_ sender: UITextField) {
        if let text = sender.text {
            let searchManager = SearchManager()
            searchManager.engageSearch(with: text)
            let presentedVC = UIStoryboard.main().instantiateViewController(withIdentifier: "Search View Controller") as! SearchTableViewController
            presentedVC.titleToShow = text
            presentedVC.searchManager = searchManager
            navigationController?.pushViewController(presentedVC, animated: true)
        }
        toggleSearch()
    }
    
    @IBAction func navigationItemTextFieldDidEnter(_ sender: UITextField) {
        if let text = sender.text {
            doSearch(text: text)
        }
        sender.text = nil
        view.endEditing(true)
        sender.resignFirstResponder()
        if isInSearch {
            toggleSearch()
        }
    }
    
    
    func loadTextViews() {
        navigationItemTitleTextField.placeholder = verseManager.description
        navigationItemTitleTextField.resignFirstResponder()
        textToPresent = verseManager.getVerses()
        layoutManager.arrayOfVerses = textToPresent
        mainCollectionView.reloadData()
    }
    
    @objc private func toggleMenu() {
        delegate?.toggleLeftPanel?()
        navigationItemTitleTextField.resignFirstResponder()
    }
    
    @objc private func toggleSearch() {
        isInSearch = !isInSearch
        if isInSearch {
            mainStackView.spacing = 10
        } else {
            mainStackView.spacing = 0
        }
        navigationItemTitleTextField.resignFirstResponder()
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
    
    // MARK: Search
    
    private func doSearch(text arrived: String) {
        let text = arrived.replacingOccurrences(of: " ", with: "")
        if text.matches(String.regexForChapter) {
            let m = text.capturedGroups(withRegex: String.regexForChapter)!
            verseManager.changeChapter(to: Int(m[0])!)
        } else if text.matches(String.regexForBookRefference) {
            let match = text.capturedGroups(withRegex: String.regexForBookRefference)!
            if verseManager.changeBook(by: match[0]),
                match.count > 1,
                let n = Int(match[1]) {
                verseManager.changeChapter(to: n)
                if match.count > 2,
                    let verseMatch = text.matches(withRegex: String.regexForVerses),
                    verseMatch[0][0] == match[1] {
                    let v = verseMatch[1...]
                    verseManager.setVerses(from: v.map {$0[0]})
                }
            }
        } else if text.matches(String.regexForVersesOnly) {
            let verseMatch = text.matches(withRegex: String.regexForVersesOnly)!
            verseManager.changeChapter(to: Int(verseMatch[0][0])!)
            let v = verseMatch[1...]
            if v.count > 0 {
                verseManager.setVerses(from: v.map {$0[0]})
            }
        }
        loadTextViews()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: nil) { (_) in
            self.mainCollectionView.reloadData()
        }
    }
}

// MARK: - UITextViewDelegate

extension MultipleTextVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return textToPresent.reduce(0) { (count, array) -> Int in
            return count + array.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TextViewCell", for: indexPath)
        let count = textToPresent.count
        let number = indexPath.row % count
        let row = indexPath.row / count
        if let c = cell as? TextCollectionViewCell {
            c.text = textToPresent[number][row]
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let count = textToPresent.count
        let row = indexPath.row / count
        let width = (collectionView.bounds.width / CGFloat(count))
        return CGSize(width: width, height: layoutManager.calculateHeight(at: row, with: width))
    }
    
}

// MARK: URLDelegate

extension MultipleTextVC: URLDelegate {
    func openedURL(with parameters: [String]) {
        navigationItemTitleTextField.resignFirstResponder()
        if overlapped {
            toggleMenu()
        }
        if parameters.count > 1 {
            switch parameters[0] {
            case "Hebrew", "Greek":
                let vc = UIStoryboard.main()
                    .instantiateViewController(withIdentifier: "StrongVC")
                    as! StrongViewController
                vc.identifier = parameters[0]
                vc.numbers = parameters[1].split(separator: "+").map {Int(String($0))!}
                if let nav = navigationController {
                    if UIDevice.current.userInterfaceIdiom == .phone {
                        nav.pushViewController(vc, animated: true)
                    } else {
                        let size = CGSize(width: 500, height: 300)
                        let nvc = UINavigationController(rootViewController: vc)
                        nvc.modalPresentationStyle = UIModalPresentationStyle.popover
                        let popover = nvc.popoverPresentationController
                        vc.preferredContentSize = size
                        popover?.sourceView = self.view
                        popover?.sourceRect = CGRect(x: (view.bounds.width / 2), y: (view.bounds.height / 2), width: 0, height: 0)
                        popover?.permittedArrowDirections = .init(rawValue: 0)
                        popover?.backgroundColor = UIColor.green
                        
                        present(nvc, animated: true, completion: nil)
                    }
                } else {
                    present(vc, animated: true, completion: nil)
                }
                presentedVC = vc
            default: break
            }
        } else {
            doSearch(text: parameters[0])
            //            parseSearch(text: parameters[0])
        }
    }
}

// MARK: SidePanelViewControllerDelegate

extension MultipleTextVC: SidePanelViewControllerDelegate {
    func didSelect(chapter: Int, in book: Int) {
        delegate?.collapseSidePanels?()
        verseManager.changeChapter(to: chapter)
        verseManager.changeBook(to: book)
    }
}

// MARK: GestureRecognizers

extension MultipleTextVC {
    @objc private func swipeLeft() {
        if overlapped {
            toggleMenu()
        }
        verseManager.incrementChapter()
        loadTextViews()
    }
    @objc private func swipeRight() {
        if overlapped {
            toggleMenu()
        }
        verseManager.decrementChapter()
        loadTextViews()
    }
    @objc private func edgePan(_ recognizer: UIScreenEdgePanGestureRecognizer) {
        if recognizer.state == .began {
            toggleMenu()
            recognizer.state = .ended
        }
    }
}

extension MultipleTextVC: ConsistencyManagerDelegate {
    //    func condidtentManagerDidUpdatedProgress(to value: Double) {
    //        print("Progress = \(value)")
    //        DispatchQueue.main.async {
    //            if !self.isLoadInProgress {
    //                self.isLoadInProgress = true
    //                self.progressView.isHidden = false
    //            }
    //            if 1.0 - value < 0.000001 {
    //                self.isLoadInProgress = false
    //                self.progressView.isHidden = true
    //            }
    //            self.progressView.progress = CGFloat(value) * 100
    //        }
    //    }
    func consistentManagerDidStartUpdate() {
        print("Start animating")
        func start() {
            DispatchQueue.main.async {
                self.progressView.startAnimating()
                self.progressView.isHidden = false
            }
        }
        start()
        executeOnAppear = start
    }
    
    func consistentManagerDidEndUpdate() {
        print("Stop animating")
        func stop() {
            DispatchQueue.main.async {
                self.progressView.isHidden = true
                self.progressView.stopAnimating()
            }
        }
        stop()
        executeOnAppear = stop
    }
}

extension MultipleTextVC: ModelUpdateDelegate {
    func modelChanged(_ fully: Bool) {
        DispatchQueue.main.async {
            self.loadTextViews()
        }
    }
}
