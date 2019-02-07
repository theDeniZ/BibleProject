//
//  HistoryViewController.swift
//  SplitB
//
//  Created by Denis Dobanda on 27.11.18.
//  Copyright © 2018 Denis Dobanda. All rights reserved.
//

import UIKit
import CoreData

class HistoryViewController: UIViewController {

    var delegate: SidePanelViewControllerDelegate?
    var context: NSManagedObjectContext! = AppDelegate.context
    
    @IBOutlet weak var table: UITableView!
    
    private var history: [History] = [] {
        didSet {
            table?.reloadData()
        }
    }
    
    override func viewDidLoad() {
        table.dataSource = self
        table.delegate = self
        if let h = try? History.get(from: context) {
            history = h
        }
    }
    @IBAction func clearAction(_ sender: UIButton) {
        History.clear(in: context)
        history = []
    }
    @IBAction func closeAction(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
}

extension HistoryViewController:UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return history.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "History Table Cell", for: indexPath)
        if let chapter = history[indexPath.row].chapter,
            let name = chapter.book?.name {
            cell.textLabel?.text = "\(name) \(chapter.number)"
        }
        return cell
    }
    
    
}

extension HistoryViewController:UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.didSelect(chapter: Int(history[indexPath.row].chapter!.number), in:Int(history[indexPath.row].chapter!.book!.number))
        dismiss(animated: true, completion: nil)
    }
}


