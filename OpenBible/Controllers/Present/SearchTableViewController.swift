//
//  SearchTableViewController.swift
//  OpenBible
//
//  Created by Denis Dobanda on 06.03.19.
//  Copyright © 2019 Denis Dobanda. All rights reserved.
//

import UIKit

class SearchTableViewController: UITableViewController {

    var titleToShow: String!
    var searchManager: SearchManager!
    
    private var results = [SearchResult]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.clearsSelectionOnViewWillAppear = false
        navigationItem.title = titleToShow
        searchManager.delegate = self
        refreshControl = UIRefreshControl()
        refreshControl?.beginRefreshing()
    }

    // MARK: - Table view data source
//
//    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 114.0
//    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Search Table View Cell", for: indexPath)

        if let c = cell as? SearchTableViewCell {
            c.title = results[indexPath.row].title
            c.textToShow = results[indexPath.row].text.replacingOccurrences(of: " \\d+", with: "", options: .regularExpression, range: nil)
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sel = results[indexPath.row].index
        AppDelegate.coreManager.changeBook(to: sel.0)
        AppDelegate.coreManager.changeChapter(to: sel.1)
        AppDelegate.coreManager.setVerses(from: ["\(sel.2)"])
        navigationController?.popViewController(animated: true)
    }

}

extension SearchTableViewController: SearchManagerDelegate {
    func searchManagerDidGetError(error: Error) {
        print("Error")
        DispatchQueue.main.async {
            self.refreshControl?.endRefreshing()
        }
    }
    
    func searchManagerDidGetUpdate(results: [SearchResult]?) {
        self.results = results ?? []
        DispatchQueue.main.async {
            self.navigationItem.title = self.titleToShow + " \(results?.count ?? 0)"
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
        }
    }
}
