//
//  ModuleManagerViewController.swift
//  macB
//
//  Created by Denis Dobanda on 25.12.18.
//  Copyright © 2018 Denis Dobanda. All rights reserved.
//

import Cocoa

class ModuleManagerViewController: NSViewController {

    @IBOutlet weak var tableView: NSTableView!
    
    var context: NSManagedObjectContext = AppDelegate.context
    
    private var modules: [Module] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let m = try? Module.getAll(from: context, local: true) {
            modules = m
        }
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        if let m = try? Module.getAll(from: context, local: true) {
            modules = m
            tableView.reloadData()
        }
    }
    
    @IBAction func clearAll(_ sender: NSButton) {
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            self?.modules.forEach {self?.context.delete($0)}
            try? self?.context.save()
            if self != nil, let m = try? Module.getAll(from: self!.context, local: true) {
                self!.modules = m
                self!.tableView.reloadData()
            }
        }
    }
    
    
}

extension ModuleManagerViewController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return modules.count
    }
}


extension ModuleManagerViewController: NSTableViewDelegate {
    //    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
    ////        let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "Download Cell"), owner: self)
    //        let r = tableView.rowView(atRow: row, makeIfNecessary: true)
    //        if let cell = r?.view(atColumn: 0) as? DownloadCellView {
    //            cell.left = modules[row].key
    //            cell.right = modules[row].name
    //            cell.loaded = false
    //        }
    //        return r
    //    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "Download Cell"), owner: self) as? DownloadCellView
        cell?.left = modules[row].key
        cell?.right = modules[row].name
        cell?.loaded = true
        cell?.delegate = self
        return cell
    }
    
}


extension ModuleManagerViewController: DownloadDelegate {
    func initiateRemoval(by key: String, completition: ((Bool) -> Void)?) {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let context = AppDelegate.context
                if let module = try Module.get(by: key, from: context) {
                    self.modules.removeAll {$0.key == key}
                    context.delete(module)
                    try context.save()
                    DispatchQueue.main.async { [weak self] in
                        self?.tableView.reloadData()
                    }
                    completition?(true)
                } else {
                    completition?(false)
                }
            } catch {
                completition?(false)
            }
        }
    }
}
