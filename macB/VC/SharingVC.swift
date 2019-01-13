//
//  SharingVC.swift
//  macB
//
//  Created by Denis Dobanda on 11.01.19.
//  Copyright © 2019 Denis Dobanda. All rights reserved.
//

import Cocoa
import QRCoder

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
    @IBOutlet private weak var actionButton: NSButton!
    
    private var options: [SharingObject]?
    private var manager: SharingManager {
        return AppDelegate.sharingManager
    }
    
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
        manager.delegate = self
        updateObjects()
    }
    
    
    @IBAction func actionButton(_ sender: NSButton) {
        switch manager.status {
        case .notReady:
            manager.becomeAvailable()
        case .connected:
            manager.terminate()
        default:
            manager.terminate()
        }
    }

    func updateObjects() {
        manager.sharingObjects = options?.filter({$0.selected})
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
            c.delegate = self
        }
        return cell
    }
}

extension SharingVC: SharingSelectingDelegate {
    func sharingObjectWasSelected(with status: Bool, being index: Int) {
        options![index].selected = status
        updateObjects()
    }
}

extension SharingVC: SharingManagerDelegate {
    func sharingManagerDidChangedStatus(to status: SharingManagerStatus) {
        switch status {
        case .notReady:
            linkLabel.stringValue = "Not ready"
            actionButton.title = "Listen"
            imageView.image = nil
        case .ready:
            if let url = manager.occupiedURL {
                linkLabel.stringValue = url
                let generator = QRCodeGenerator()
                if let image = generator.createImage(value: url, size: imageView.bounds.size) {
                    imageView.image = image
                }
            } else {
                linkLabel.stringValue = "No url, ready on \(manager.port)"
                imageView.image = nil
            }
            actionButton.title = "Close"
        case .failed(let error):
            linkLabel.stringValue = "Fail: \(error)"
            actionButton.title = "Listen"
            imageView.image = nil
        case .connected(let address):
            actionButton.title = "Terminate"
            linkLabel.stringValue = "Connected at \(address)"
            imageView.image = nil
        default:
            linkLabel.stringValue = "not recognized"
            actionButton.title = "Listen"
            imageView.image = nil
        }
    }
}
