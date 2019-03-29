//
//  MultipleTextVC.swift
//  OpenBible
//
//  Created by Denis Dobanda on 11.03.19.
//  Copyright © 2019 Denis Dobanda. All rights reserved.
//

import UIKit

class MultipleTextVC: UIViewController, ContainingViewController, Storyboarded {
    
    var verseManager = AppDelegate.coreManager
    var overlapped: Bool = false
    
    var coordinator: MainPreviewCoordinator?
    
    // MARK: Private implementation
    
    @IBOutlet private weak var mainCollectionView: UICollectionView!
    @IBOutlet private weak var searchTextField: UITextField!
    @IBOutlet private weak var progressView: ProgressView!
    @IBOutlet private weak var mainStackView: UIStackView!
    
    @IBOutlet private weak var navigationItemTitleTextField: UITextField!
    
    private var leftTextStorage: NSTextStorage?
    private var rightTextStorage: NSTextStorage?
    private var presentedVC: UIViewController?
    private var draggedScrollView: Int = 0
    private var executeOnAppear: (() -> ())?
    
    private var textToPresent = [[NSAttributedString]]()
    private var layoutManager = CVLayoutManager()
    
    private var isInSearch: Bool = false {didSet{updateSearchUI()}}
    private var countOfPortraitModulesAtOnce: Int {
        return AppDelegate.plistManager.portraitNumber
    }
    
    // MARK: - Actions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mainStackView.spacing = 0
        progressView.isHidden = true
        AppDelegate.shared.consistentManager.addDelegate(self)
        AppDelegate.shared.urlDelegate = self
//        countOfPortraitModulesAtOnce = AppDelegate.plistManager.portraitNumber
        verseManager.addDelegate(self)
//        loadTextViews()
        mainCollectionView.dataSource = self
        mainCollectionView.delegate = self
        mainCollectionView.isUserInteractionEnabled = true
        
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadTextViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        progressView.initialiseGradient()
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
//        DispatchQueue.global(qos: .userInteractive).async {
            self.textToPresent = self.verseManager.getVerses()
            if UIDevice.current.orientation == .portrait, self.textToPresent.count > self.countOfPortraitModulesAtOnce {
                self.textToPresent = Array(self.textToPresent[..<self.countOfPortraitModulesAtOnce])
            }
            self.layoutManager.arrayOfVerses = self.textToPresent
//            DispatchQueue.main.async {
                self.mainCollectionView.reloadData()
//            }
//        }
    }
    
    @objc private func toggleMenu() {
        navigationItemTitleTextField.resignFirstResponder()
        coordinator?.toggleMenu()
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
    
    func doSearch(text arrived: String) {
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
            self.loadTextViews()
            self.mainCollectionView.reloadData()
            self.progressView.initialiseGradient()
        }
    }
    
    func setNeedsLoad() {
        loadTextViews()
    }
}

// MARK: - UITextViewDelegate

extension MultipleTextVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return textToPresent.countMax * textToPresent.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TextViewCell", for: indexPath)
        let count = textToPresent.count
        let number = indexPath.row % count
        let row = indexPath.row / count
        if let c = cell as? TextCollectionViewCell {
            if textToPresent[number].count > row {
                c.text = textToPresent[number][row]
                c.index = (number, row)
                c.delegate = verseManager
                c.presentee = self
            } else {
                c.text = NSAttributedString(string: "")
                c.index = nil
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let count = textToPresent.count
        let row = indexPath.row / count
        let width = (collectionView.bounds.width - 1.0) / CGFloat(count)
        return CGSize(width: width, height: layoutManager.calculateHeight(at: row, with: width))
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        collectionView.deselectItem(at: indexPath, animated: true)
        let count = textToPresent.count
        let number = indexPath.row % count
        let row = indexPath.row / count
        print((number, row))
    }
}

// MARK: URLDelegate

extension MultipleTextVC: URLDelegate {
    func openedURL(with parameters: [String]) {
        coordinator?.openLink(parameters)
    }
    
    private func present(vc: UIViewController, with size: CGSize) {
        let nvc = UINavigationController(rootViewController: vc)
        nvc.modalPresentationStyle = UIModalPresentationStyle.popover
        let popover = nvc.popoverPresentationController
        vc.preferredContentSize = size
        popover?.sourceView = self.view
        popover?.sourceRect = CGRect(x: (view.bounds.width / 2), y: (view.bounds.height / 2), width: 0, height: 0)
        popover?.permittedArrowDirections = .init(rawValue: 0)
//        popover?.backgroundColor = UIColor.green
        
        present(nvc, animated: true, completion: nil)
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
//        countOfPortraitModulesAtOnce = AppDelegate.plistManager.portraitNumber
        DispatchQueue.main.async {
            self.loadTextViews()
        }
    }
}

extension MultipleTextVC: UIPresentee {
    func presentNote(at index: (Int, Int)) {
//        guard let note = verseManager.isThereANote(at: index) else {return}
        presentMenu(at: index)
    }
    
    func presentMenu(at index: (Int, Int)) {
        if UIDevice.current.userInterfaceIdiom == .phone {
            AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
            presentOniPhone(at: index)
        } else {
            presentOniPad(at: index)
        }
    }
    
    private func presentOniPhone(at index: (Int, Int)) {
        let pvc = UIStoryboard.main().instantiateViewController(withIdentifier: "Note VC") as! NoteViewController
        pvc.modalPresentationStyle = UIModalPresentationStyle.custom
        pvc.transitioningDelegate = self
        pvc.delegate = verseManager
        pvc.resignDelegate = self
        pvc.index = index
        let item = (index.1 * textToPresent.count) + index.0
        mainCollectionView.scrollToItem(at: IndexPath(row: item, section: 0), at: .top, animated: true)
        self.present(pvc, animated: true, completion: nil)
    }

    private func presentOniPad(at index: (Int, Int)) {
        let pvc = UIStoryboard.main().instantiateViewController(withIdentifier: "Note VC") as! NoteViewController
        
        pvc.delegate = verseManager
        pvc.resignDelegate = self
        pvc.index = index
        pvc.makingCustomSize = false
        let item = (index.1 * textToPresent.count) + index.0
        mainCollectionView.scrollToItem(at: IndexPath(row: item, section: 0), at: .top, animated: true)
        
        let size = CGSize(width: 300, height: 300)
        present(vc: pvc, with: size)
//        self.present(pvc, animated: true, completion: nil)
    }
}

extension MultipleTextVC: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return HalfSizePresentationController(presentedViewController: presented, presenting: presenting)
    }
}

class HalfSizePresentationController : UIPresentationController {
    override var frameOfPresentedViewInContainerView: CGRect {
        return containerView!.bounds
    }
}

extension MultipleTextVC: UIResignDelegate {
    func viewControllerWillResign() {
        DispatchQueue.main.async {
            self.mainCollectionView.reloadData()
        }
    }
}
