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
        ModuleOffline("Schlachter 1951", "schlachter"),
        ModuleOffline("KJV Easy Read", "akjv"),
        ModuleOffline("American Standard Version", "asv"),
        ModuleOffline("World English Bible", "web"),
        ModuleOffline("Luther (1912)", "luther1912"),
        ModuleOffline("Elberfelder (1871)", "elberfelder"),
        ModuleOffline("Elberfelder (1905)", "elberfelder1905"),
        ModuleOffline("Luther (1545)", "luther1545"),
        ModuleOffline("Textus Receptus", "text"),
        ModuleOffline("NT Textus Receptus (1550 1894) Parsed", "textusreceptus"),
        ModuleOffline("Hebrew Modern", "modernhebrew"),
        ModuleOffline("Aleppo Codex", "aleppo"),
        ModuleOffline("OT Westminster Leningrad Codex", "codex"),
        ModuleOffline("Hungarian Karoli", "karoli"),
        ModuleOffline("Vulgata Clementina", "vulgate"),
        ModuleOffline("Almeida Atualizada", "almeida"),
        ModuleOffline("Cornilescu", "cornilescu"),
        ModuleOffline("Synodal Translation (1876)", "synodal"),
        ModuleOffline("Makarij Translation Pentateuch (1825)", "makarij"),
        ModuleOffline("Sagradas Escrituras", "sse"),
        ModuleOffline("NT (P Kulish 1871)", "ukranian")
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
}


extension DownloadTableViewController: NSTableViewDelegate {
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
        cell?.loaded = false
        cell?.delegate = self
        return cell
    }
    
}


extension DownloadTableViewController: DownloadDelegate {
    func initiateRemoval(by key: String, completition: ((Bool) -> Void)?) {
        print("removed")
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { (t) in
            completition?(true)
            t.invalidate()
        }
    }
    
    func initiateDownload(by key: String, completition: ((Bool) -> Void)?) {
        print("downloaded")
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { (t) in
            completition?(true)
            t.invalidate()
        }
    }
}
