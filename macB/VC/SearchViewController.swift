//
//  SearchViewController.swift
//  macB
//
//  Created by Denis Dobanda on 06.03.19.
//  Copyright © 2019 Denis Dobanda. All rights reserved.
//

import Cocoa

class SearchViewController: NSViewController {
    
    @IBOutlet private weak var searchField: NSSearchField!
    @IBOutlet private weak var table: NSTableView!
    @IBOutlet private weak var progressIndicator: NSProgressIndicator!
    
    private let cellIdentifier = "Search Table View Cell"
    
    private var founded: [SearchResult] = []
    private var searchManager = SearchManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        table.dataSource = self
        table.delegate = self
        searchManager.delegate = self
        progressIndicator.isHidden = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(tableViewDidSelectRow), name: NSTableView.selectionDidChangeNotification, object: table)
    }
    
    @IBAction func doSearch(_ sender: NSSearchField) {
        if sender.stringValue.count > 0 {
            progressIndicator.isHidden = false
            searchField.isEnabled = false
            searchManager.engageSearch(with: sender.stringValue)
        }
    }
    
    @objc private func tableViewDidSelectRow() {
        let index = founded[table.selectedRow].index
        AppDelegate.coreManager.changeBook(to: index.0)
        AppDelegate.coreManager.changeChapter(to: index.1)
        AppDelegate.coreManager.setVerses(from: ["\(index.2)"])
    }
    
}

extension SearchViewController: SearchManagerDelegate {
    func searchManagerDidGetError(error: Error) {
        print(error)
    }
    func searchManagerDidGetUpdate(results: [SearchResult]?) {
        self.founded = results ?? []
        DispatchQueue.main.async {
            self.table.reloadData()
            self.progressIndicator.stopAnimation(nil)
            self.progressIndicator.isHidden = true
            self.searchField.isEnabled = true
        }
    }
}

extension SearchViewController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return founded.count
    }
}

extension SearchViewController: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier.init(cellIdentifier), owner: self)
        
        if let c = cell as? SearchTableCellView {
            c.leftText = founded[row].title
            c.rightText = founded[row].text.replacingOccurrences(of: " \\d+", with: "", options: .regularExpression, range: nil)
        }
        
        return cell
    }
}
