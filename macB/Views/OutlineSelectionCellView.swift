//
//  OutlineSelectionCellView.swift
//  macB
//
//  Created by Denis Dobanda on 13.02.19.
//  Copyright © 2019 Denis Dobanda. All rights reserved.
//

import Cocoa

class OutlineSelectionCellView: NSTableCellView {
    var delegate: OutlineSelectionDelegate? {didSet{updateUI()}}
    var count: Int = 0 {didSet{updateUI()}}
    var indexInOverall = 0 {didSet{updateUI()}}
    var module: String?
    
    @IBOutlet weak var table: NSTableView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        table.delegate = self
        table.dataSource = self
        table.deselectAll(nil)
    }
    
    private func updateUI() {
        table?.reloadData()
        table.deselectAll(nil)
    }
    
}

extension OutlineSelectionCellView: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        delegate?.outlineSelectionViewDidSelect(chapter: row + 1, book: indexInOverall + 1, module: module)
        return true
    }
}

extension OutlineSelectionCellView: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return count
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        return row + 1
    }
}
