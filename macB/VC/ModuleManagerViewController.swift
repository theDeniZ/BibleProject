//
//  ModuleManagerViewController.swift
//  macB
//
//  Created by Denis Dobanda on 25.12.18.
//  Copyright © 2018 Denis Dobanda. All rights reserved.
//

import Cocoa

struct PresentedCoreObject {
    var key: String
    var title: String
    var data: NSManagedObject
}

class ModuleManagerViewController: NSViewController {

    @IBOutlet weak var tableView: NSTableView!
    
    var context: NSManagedObjectContext = AppDelegate.context
    
    private var modules: [PresentedCoreObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        reloadModules()
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        reloadModules()
    }
    
    @IBAction func clearAll(_ sender: NSButton) {
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            self?.modules.forEach {self?.context.delete($0.data)}
            try? self?.context.save()
            self?.reloadModules()
        }
    }
    
    private func reloadModules() {
        modules = []
        if let bibles = try? Module.getAll(from: context, local: true) {
            modules.append(contentsOf: bibles.map({PresentedCoreObject(key: $0.key ?? "", title: $0.name ?? "", data: $0)}))
        }
//        if Strong.exists(StrongIdentifier.oldTestament, in: context) {
//
//        }
        if let spirit = try? SpiritBook.getAll(from: context) {
            modules.append(contentsOf: spirit.map({PresentedCoreObject(key: $0.code ?? "", title: $0.name ?? "", data: $0)}))
        }
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
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
        let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "Download Cell"), owner: self)
        if let c = cell as? DownloadCellView {
            c.left = modules[row].key
            c.right = modules[row].title
            c.loaded = true
            c.delegate = self
            c.index = row
        }
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
    
    func initiateRemoval(by index: Int, completition: ((Bool) -> Void)?) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            if self != nil {
                self!.context.delete(self!.modules[index].data)
                self!.modules.remove(at: index)
                try? self!.context.save()
                DispatchQueue.main.async { [weak self] in
                    self!.tableView.reloadData()
                }
                completition?(true)
            } else {
                completition?(false)
            }
            
        }
    }
}
