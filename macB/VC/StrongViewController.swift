//
//  StrongViewController.swift
//  macB
//
//  Created by Denis Dobanda on 30.12.18.
//  Copyright © 2018 Denis Dobanda. All rights reserved.
//

import Cocoa

class StrongViewController: NSViewController {

    var context: NSManagedObjectContext = AppDelegate.context
    var identifierStrong: String = StrongIdentifier.oldTestament
    
    @IBOutlet private weak var table: NSTableView!
    @IBOutlet weak var searchField: NSTextField!
    
    private var numbers: [Strong] = [] {didSet{table?.reloadData()}}
    private var searchPhrase: String? {didSet{load()}}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        table.dataSource = self
        table.delegate = self
        load()
    }
    
    private func load() {
        if searchPhrase == nil, let n = try? Strong.get(by: identifierStrong, from: context) {
            numbers = n
        } else if !searchPhrase!.matches("\\d+") {
            numbers = Strong.get(by: identifierStrong, searched: searchPhrase!, from: context)
        } else if let s = Strong.get(Int(searchPhrase!)!, by: identifierStrong, from: context) {
            numbers = [s]
        } else {
            numbers = []
        }
    }
    
    @IBAction func selectedSegment(_ sender: NSSegmentedCell) {
        if sender.selectedSegment == 0 {
            identifierStrong = StrongIdentifier.oldTestament
        } else {
            identifierStrong = StrongIdentifier.newTestament
        }
        load()
    }
    
    @IBAction func searchShouldReturn(_ sender: NSTextField) {
        searchPhrase = sender.stringValue == "" ? nil : sender.stringValue
    }
    
    
}

extension StrongViewController: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        switch tableColumn?.identifier {
        case NSUserInterfaceItemIdentifier(rawValue: "Number Column"):
            if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "Number Cell"), owner: self) as? LabelCellView {
                cell.text = "\(numbers[row].number)"
                return cell
            }
        case NSUserInterfaceItemIdentifier(rawValue: "Original Column"):
            if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "Original Cell"), owner: self) as? LabelCellView {
                cell.text = numbers[row].original
                return cell
            }
        case NSUserInterfaceItemIdentifier(rawValue: "Meaning Column"):
            if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "Meaning Cell"), owner: self) as? LabelCellView {
                cell.text = numbers[row].meaning
                return cell
            }
        default: break
        }
        return nil
    }
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        if let vc = NSStoryboard.main?.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("Detail Strong VC")) as? StrongDetailViewController {
            vc.numbers = [Int(numbers[row].number)]
            vc.identifierStrong = identifierStrong
            presentAsModalWindow(vc)
        }
        return false
    }
    
}

extension StrongViewController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return numbers.count
    }
}
