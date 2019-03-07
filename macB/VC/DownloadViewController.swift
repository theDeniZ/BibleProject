//
//  DownloadViewController.swift
//  macB
//
//  Created by Denis Dobanda on 07.03.19.
//  Copyright © 2019 Denis Dobanda. All rights reserved.
//

import Cocoa

class DownloadViewController: NSViewController {
    
    @IBOutlet private weak var table: NSTableView!
    @IBOutlet private weak var refreshControl: NSProgressIndicator!
    
    private var modules = [(size: String, name: String, loaded: Bool, path: String)]()
    private var strongs = [(size: String, name: String, loaded: Bool, path: String)]()
    private var spirit = [(size: String, name: String, loaded: Bool, path: String)]()
    
    private var dowlnoadCellViewIdentifier = "Download Cell View"
    
    private let manager = AppDelegate.consistentManager
    
    override func viewDidLoad() {
        super.viewDidLoad()
        table.dataSource = self
        table.delegate = self
        refreshControl.startAnimation(nil)
        refreshControl.isHidden = false
        readFromServer()
    }
    
    private func readFromServer() {
        guard modules.count == 0, strongs.count == 0, spirit.count == 0 else {return}
        let context = AppDelegate.context
        guard let url = URL(string: AppDelegate.downloadServerURL) else {return}
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil {
                print(error!)
            }
            if data != nil,
                let json = try? JSONSerialization.jsonObject(
                    with: data!, options: .allowFragments
                    ) as? [[String:String]],
                let array = json {
                for file in array {
                    if let name = file["name"],
                        let size = file["size"],
                        let path = file["path"],
                        let regex = file["key"] {
                        if let key = SharingRegex.parseModule(regex) {
                            let exist = Module.exists(key: key, in: context)
                            self.modules.append((size, name, exist, path))
                        } else if let key = SharingRegex.parseStrong(regex) {
                            let exist = (try? Strong.exists(key, in: context)) ?? false
                            self.strongs.append((size, name, exist, path))
                        } else if let key = SharingRegex.parseSpirit(regex) {
                            let exist = SpiritBook.exists(with: key, in: context)
                            self.spirit.append((size, name, exist, path))
                        }
                    }
                }
            } else {
                print("No readable data is arrived")
            }
            DispatchQueue.main.async {
                self.table.reloadData()
                self.refreshControl.isHidden = true
                self.refreshControl.stopAnimation(nil)
            }
        }
        task.resume()
    }
}

extension DownloadViewController: NSTableViewDataSource, NSTableViewDelegate {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return modules.count + strongs.count + spirit.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier.init(dowlnoadCellViewIdentifier), owner: self)
        
        var index = 0
        var arrayToUse = 0
        if row < modules.count {
            index = row
            arrayToUse = 0
        } else if row < modules.count + strongs.count {
            index = row - modules.count
            arrayToUse = 1
        } else {
            index = row - modules.count - strongs.count
            arrayToUse = 2
        }
        
        let selected = arrayToUse == 0 ? modules[index] : arrayToUse == 1 ? strongs[index] : spirit[index]
        if let c = cell as? DownloadCellView {
            c.index = (arrayToUse, index)
            c.left = selected.size
            c.right = selected.name
            c.isLoaded = selected.loaded
            c.delegate = self
        }
        
        return cell
    }
}

extension DownloadViewController: DownloadDelegate {
    func download(index: (Int, Int), completition: ((Bool) -> ())?) {
        let selected = index.0 == 0 ? modules[index.1] : index.0 == 1 ? strongs[index.1] : spirit[index.1]
        manager.download(file: selected.path) { (success) in
            completition?(success)
            AppDelegate.coreManager.update()
        }
    }
    
    func remove(index: (Int, Int), completition: ((Bool) -> ())?) {
        let selected = index.0 == 0 ? modules[index.1] : index.0 == 1 ? strongs[index.1] : spirit[index.1]
        manager.remove(selected.path) {
            completition?(true)
            AppDelegate.coreManager.update()
            
        }
    }
}
