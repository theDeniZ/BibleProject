//
//  OutlineViewController.swift
//  macB
//
//  Created by Denis Dobanda on 13.02.19.
//  Copyright © 2019 Denis Dobanda. All rights reserved.
//

import Cocoa

class OutlineViewController: NSViewController {
    
    @IBOutlet weak var outline: NSOutlineView!
    
    var listed: [ListRoot] = []
    var typesToDisplay: [ListType]? = [ListType.bible]
    var delegate: OutlineSelectionDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let manager = ListManager()
        manager.typesToDisplay = typesToDisplay
        listed = manager.getListOfAll()
        outline.dataSource = self
        outline.delegate = self
    }
    
}

extension OutlineViewController: NSOutlineViewDataSource {
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if let root = item as? ListRoot {
            return root.container.count
        } else if let list = item as? ListObject {
            return list.nested.count
        } else {
            return listed[0].container.count
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
            return listed[0].container[index]
        }
    }
}

extension OutlineViewController: NSOutlineViewDelegate {
    
//    func outlineView(_ outlineView: NSOutlineView, shouldSelectItem item: Any) -> Bool {
//        return false
//    }
//
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        
        if let root = item as? ListRoot {
            let cell = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier.init("Outline Cell"), owner: self)
            let c = cell as! OutlineCellView
            c.title = root.typeName
            return cell
        } else if let list = item as? ListObject {
            if list.nested.count > 0 {
                let cell = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier.init("Outline Cell"), owner: self)
                let c = cell as! OutlineCellView
                c.title = list.title
                return cell
            } else {
                let cell = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier.init("Outline Cell Selection"), owner: self)
                let c = cell as! OutlineSelectionCellView
                c.count = Int(list.title.split(separator: " ")[0])!
                c.delegate = delegate
                c.indexInOverall = list.numberInOrder ?? 0
                c.module = list.moduleKey
                return cell
            }
        }
        return nil
    }
    
    func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat {
        if let i = item as? ListObject, i.nested.count == 0 {
            return 100
        }
        return 17
    }
    
//    func outlineView(_ outlineView: NSOutlineView, objectValueFor tableColumn: NSTableColumn?, byItem item: Any?) -> Any? {
//        if let root = item as? ListRoot {
//            return root.typeName
//        } else if let list = item as? ListObject {
//            return list.title
//        } else {
//            return "Content"
//        }
//    }
    

    
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
