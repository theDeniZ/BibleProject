//
//  ListViewController.swift
//  macB
//
//  Created by Denis Dobanda on 20.01.19.
//  Copyright © 2019 Denis Dobanda. All rights reserved.
//

import Cocoa

class ListViewController: NSViewController {

    @IBOutlet weak var outline: NSOutlineView!
    
    var listed: [ListRoot] = []
    var typesToDisplay: [ListType]?
    var delegate: SideMenuDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let manager = ListManager()
        manager.typesToDisplay = typesToDisplay
        listed = manager.getListOfAll()
        outline.dataSource = self
        outline.delegate = self
    }
    
}

extension ListViewController: NSOutlineViewDataSource {
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if let root = item as? ListRoot {
            return root.container.count
        } else if let list = item as? ListObject {
            return list.nested.count
        } else {
            return listed.count
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        if let root = item as? ListRoot {
            return root.container.count > 0
        } else if let list = item as? ListObject {
            return list.nested.count > 0
        } else {
            return listed.count > 0
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if let root = item as? ListRoot {
            return root.container[index]
        } else if let list = item as? ListObject {
            return list.nested[index]
        } else {
            return listed[index]
        }
    }
}

extension ListViewController: NSOutlineViewDelegate {
    
    func outlineView(_ outlineView: NSOutlineView, objectValueFor tableColumn: NSTableColumn?, byItem item: Any?) -> Any? {
        if let root = item as? ListRoot {
            return root.typeName
        } else if let list = item as? ListObject {
            return list.title
        } else {
            return "Content"
        }
    }
    
    @objc func outlineViewSelectionDidChange(_ notification: Notification) {
        if let selected = outline.item(atRow: outline.selectedRow) as? ListObject,
            let index = selected.index {
            delegate?.sideMenuDidSelect(index: index)
        }
    }
    
//    func outlineView(_ outlineView: NSOutlineView, dataCellFor tableColumn: NSTableColumn?, item: Any) -> NSCell? {
//        let cell = NSTextFieldCell()
//        if let root = item as? ListRoot {
//            cell.title = root.typeName
//        } else if let list = item as? ListObject {
//            cell.title = list.title
//        } else {
//            cell.title = "Content"
//        }
//        return cell
//    }
    
//    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
//
//
//    }
}
