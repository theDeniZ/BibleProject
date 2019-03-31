//
//  MultipleTextVC.swift
//  OpenBible
//
//  Created by Denis Dobanda on 11.03.19.
//  Copyright © 2019 Denis Dobanda. All rights reserved.
//

import UIKit

class MultipleTextVC: UIViewController, Storyboarded {
    
//    var verseManager = AppDelegate.coreManager
    
    var coordinator: MainPreviewCoordinator!
    
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
    
    private var textToPresent = [[Presentable]]()
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
//        verseManager.addDelegate(self)
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
            coordinator.doSearch(text: text)
        }
        sender.text = nil
        view.endEditing(true)
        sender.resignFirstResponder()
        if isInSearch {
            toggleSearch()
        }
    }
    
    func loadTextViews() {
        navigationItemTitleTextField.placeholder = coordinator.description
        navigationItemTitleTextField.resignFirstResponder()
//        DispatchQueue.global(qos: .userInteractive).async {
            self.textToPresent = coordinator.getDataToPresent()
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
            searchTextField.becomeFirstResponder()
        } else {
            searchTextField.isHidden = true
            searchTextField.text = nil
            view.endEditing(true)
        }
    }
    
    // MARK: Search
    

    
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
    
    func reloadData() {
        DispatchQueue.main.async { [weak self] in
            self?.mainCollectionView.reloadData()
        }
    }
    
    func scroll(to index: (Int, Int)) {
        let item = ((index.1 - 1) * textToPresent.count) + index.0
        mainCollectionView.scrollToItem(at: IndexPath(row: item, section: 0), at: .top, animated: true)
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
                c.text = textToPresent[number][row].attributedString
                c.index = (number, textToPresent[number][row].index)
                c.delegate = coordinator.modelVerseDelegate
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
}

// MARK: GestureRecognizers

extension MultipleTextVC {
    @objc private func swipeLeft() {
//        verseManager.incrementChapter()
//        loadTextViews()
        coordinator.swipe(.left)
    }
    @objc private func swipeRight() {
//        verseManager.decrementChapter()
//        loadTextViews()
        coordinator.swipe(.right)
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

// MARK: - redo
//extension MultipleTextVC: ModelUpdateDelegate {
//    func modelChanged(_ fully: Bool) {
////        countOfPortraitModulesAtOnce = AppDelegate.plistManager.portraitNumber
//        DispatchQueue.main.async {
//            self.loadTextViews()
//        }
//    }
//}

extension MultipleTextVC: UIPresentee {
    func presentNote(at index: (Int, Int)) {
//        guard let note = verseManager.isThereANote(at: index) else {return}
        presentMenu(at: index)
    }
    
    func presentMenu(at index: (Int, Int)) {
        if UIDevice.current.userInterfaceIdiom == .phone {
            AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
            coordinator.presentOniPhone(at: index)
        } else {
            coordinator.presentOniPad(at: index)
        }
    }
}
