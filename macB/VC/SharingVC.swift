//
//  SharingVC.swift
//  macB
//
//  Created by Denis Dobanda on 11.01.19.
//  Copyright © 2019 Denis Dobanda. All rights reserved.
//

import Cocoa

struct SharingObject {
    var title: String
    var coreObj: NSManagedObject?
    var additionalIdentificator: String? = nil
    var selected: Bool = true
    
    init(_ title: String, being obj: NSManagedObject?, selected sel: Bool = true, addInf additional: String? = nil) {
        self.title = title
        coreObj = obj
        selected = sel
        additionalIdentificator = additional
    }
}

class SharingVC: NSViewController {

    var context: NSManagedObjectContext = AppDelegate.context
    
    @IBOutlet private weak var table: NSTableView!
    @IBOutlet private weak var linkLabel: NSTextField!
    @IBOutlet private weak var imageView: NSImageView!
    
    private var options: [SharingObject]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let modules = try? Module.getAll(from: context) {
            options = modules.map {SharingObject($0.name!, being: $0)}
        }
        if let exists = try? Strong.exists(StrongIdentifier.oldTestament, in: context), exists {
            options?.append(
                SharingObject("Strong's Numbers (\(StrongIdentifier.oldTestament))",
                    being: nil, selected: true, addInf: StrongIdentifier.oldTestament)
            )
        }
        if let exists = try? Strong.exists(StrongIdentifier.newTestament, in: context), exists {
            options?.append(
                SharingObject("Strong's Numbers (\(StrongIdentifier.newTestament))",
                    being: nil, selected: true, addInf: StrongIdentifier.newTestament)
            )
        }
        
        table.dataSource = self
        table.delegate = self
    }
    
}

extension SharingVC: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return options?.count ?? 0
    }
}

extension SharingVC: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = table.makeView(withIdentifier: NSUserInterfaceItemIdentifier.init("Sharing Cell"), owner: self)
        
        if let c = cell as? SharingTCV {
            c.title = options![row].title
            c.checked = options![row].selected
            c.index = row
        }
        return cell
    }
}

extension SharingVC: SharingSelectingDelegate {
    func sharingObjectWasSelected(with status: Bool, being index: Int) {
        options![index].selected = status
    }
}
