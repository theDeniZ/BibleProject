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
    var key: String?
    var coreObj: NSManagedObject?
    var additionalIdentificator: String? = nil
    var selected: Bool = true
    
    init(_ title: String, key: String?, being obj: NSManagedObject?, selected sel: Bool = true, addInf additional: String? = nil) {
        self.title = title
        self.key = key
        coreObj = obj
        selected = sel
        additionalIdentificator = additional
    }
}

class SharingVC: NSViewController {

    var context: NSManagedObjectContext = AppDelegate.context
    
    @IBOutlet private weak var table: NSTableView!
    
    private var options: [SharingObject]?
    private var selected: [String:String]?
    
    private var hashableOptions: [String:String]? {
        guard let objects = options else {return nil}
        var writeable = [String:String]()
        for obj in objects.filter({$0.selected}) {
            if let key = obj.key {
                writeable[key] = obj.title
            } else if obj.additionalIdentificator == StrongIdentifier.oldTestament ||
                obj.additionalIdentificator == StrongIdentifier.newTestament {
                writeable[obj.additionalIdentificator!] = obj.additionalIdentificator!
            }
        }
        return writeable
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        selected = AppDelegate.plistManager.getSharedObjects()
        if let modules = try? Module.getAll(from: context) {
            options = modules.filter({$0.key != nil}).map
                {SharingObject($0.name!, key: $0.key!, being: $0, selected: selected?.index(forKey: $0.key!) != nil)}
        }
        if let exists = try? Strong.exists(StrongIdentifier.oldTestament, in: context), exists {
            options?.append(
                SharingObject("Strong's Numbers (\(StrongIdentifier.oldTestament))", key: nil,
                    being: nil,
                    selected: selected?.index(forKey: StrongIdentifier.oldTestament) != nil,
                    addInf: StrongIdentifier.oldTestament
                )
            )
        }
        if let exists = try? Strong.exists(StrongIdentifier.newTestament, in: context), exists {
            options?.append(
                SharingObject("Strong's Numbers (\(StrongIdentifier.newTestament))", key: nil,
                    being: nil,
                    selected: selected?.index(forKey: StrongIdentifier.newTestament) != nil,
                    addInf: StrongIdentifier.newTestament
                )
            )
        }
        if let exists = try? SpiritBook.getAll(from: context), exists.count > 0 {
            for book in exists {
                if let code = book.code {
                    options?.append(
                        SharingObject(code,
                            key: code, being: nil,
                            selected: selected?.index(forKey: code) != nil,
                            addInf: "Spirit"
                        )
                    )
                }
            }
        }
        table.dataSource = self
        table.delegate = self
    }
}

extension SharingVC: SharingSelectingDelegate {
    func sharingObjectWasSelected(with status: Bool, being i: Int) {
        options![i].selected = status
        let hashable = hashableOptions!
        AppDelegate.plistManager.setShared(objects: hashable)
        AppDelegate.shared.rewriteSharingObjects(hashable)
    }
}

extension SharingVC: NSTableViewDataSource, NSTableViewDelegate {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return options?.count ?? 0
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier.init("Sharing Cell"), owner: self)
        if let c = cell as? SharingTCV {
            c.title = options![row].title
            c.index = row
            c.checked = options![row].selected
            c.delegate = self
        }
        return cell
    }

}
