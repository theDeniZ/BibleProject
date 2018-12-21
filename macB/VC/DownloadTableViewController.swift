//
//  DownloadTableViewController.swift
//  macB
//
//  Created by Denis Dobanda on 21.12.18.
//  Copyright © 2018 Denis Dobanda. All rights reserved.
//

import Cocoa

class DownloadTableViewController: NSViewController {

    @IBOutlet weak var tableView: NSTableView!
    
    private let modules: [ModuleOffline] = [
        ModuleOffline("King James Version", "kjv"),
        ModuleOffline("American King James Version", "akjv"),
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
    }
    
}

extension DownloadTableViewController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return modules.count
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
//        let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "Download Cell"), owner: nil) as! DownloadCellView
//        cell.left = modules[row].key
//        cell.right = modules[row].name
//        cell.loaded = false
        return modules[row]
    }
}

extension DownloadTableViewController: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, didAdd rowView: NSTableRowView, forRow row: Int) {
        
    }
}
