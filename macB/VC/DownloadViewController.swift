//
//  DownloadViewController.swift
//  macB
//
//  Created by Denis Dobanda on 07.03.19.
//  Copyright © 2019 Denis Dobanda. All rights reserved.
//

import Cocoa

class DownloadViewController: NSViewController {
    
    @IBOutlet private weak var tableModule: NSTableView!
    @IBOutlet private weak var tableStrongs: NSTableView!
    @IBOutlet private weak var tableSpirit: NSTableView!
    
    @IBOutlet weak var downloadAll: NSButton!
    
    @IBOutlet private weak var refreshControl: NSProgressIndicator!
    
    private var modules = [DownloadModel]()
    private var strongs = [DownloadModel]()
    private var spirit = [DownloadModel]()
    
    private var allExists = false
    private var numberOfBackgroundProccesses = 0
    private var numberOfProceededProccesses = 0 {
        didSet {
            if numberOfProceededProccesses == numberOfBackgroundProccesses {
                numberOfBackgroundProccesses = 0
                numberOfProceededProccesses = 0
                DispatchQueue.main.async {
                    self.downloadAll.title = self.allExists ? "Remove All" : "Download All"
                    self.downloadAll.isEnabled = true
                }
            }
        }
    }
    
    private var dowlnoadCellViewIdentifier = "Download Cell View"
    
    private var manager: ConsistencyManager { return AppDelegate.consistentManager }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableModule.dataSource = self
        tableModule.delegate = self
        tableStrongs.dataSource = self
        tableStrongs.delegate = self
        tableSpirit.dataSource = self
        tableSpirit.delegate = self
        refreshControl.startAnimation(nil)
        refreshControl.isHidden = false
        readFromServer()
    }
    
    @IBAction func downloadAllAction(_ sender: NSButton) {
        downloadAll.isEnabled = false
        if allExists {
            DispatchQueue.global(qos: .userInteractive).async {
                self.removeNeeded(self.modules, table: self.tableModule)
            }
            DispatchQueue.global(qos: .userInteractive).async {
                self.removeNeeded(self.strongs, table: self.tableStrongs)
            }
            DispatchQueue.global(qos: .userInteractive).async {
                self.removeNeeded(self.spirit, table: self.tableSpirit)
            }
        } else {
            DispatchQueue.global(qos: .userInteractive).async {
                self.downloadNeeded(self.modules, table: self.tableModule)
            }
            DispatchQueue.global(qos: .userInteractive).async {
                self.downloadNeeded(self.strongs, table: self.tableStrongs)
            }
            DispatchQueue.global(qos: .userInteractive).async {
                self.downloadNeeded(self.spirit, table: self.tableSpirit)
            }
        }
        allExists = !allExists
    }
    
    private func downloadNeeded(_ array: [DownloadModel], table: NSTableView!) {
        for obj in array {
            if !obj.loaded {
                obj.loading = true
                numberOfBackgroundProccesses += 1
                DispatchQueue.main.async {
                    table?.reloadData()
                }
                DispatchQueue.global(qos: .userInitiated).async {
                    self.manager.download(file: obj.path, completition: { (sucess) in
                        obj.loaded = sucess
                        obj.loading = false
                        self.numberOfProceededProccesses += 1
                        AppDelegate.updateManagers()
                        DispatchQueue.main.async {
                            table?.reloadData()
                        }
                    })
                }
            }
        }
    }
    
    private func removeNeeded(_ array: [DownloadModel], table: NSTableView!) {
        for obj in array {
            if obj.loaded {
                obj.loading = true
                numberOfBackgroundProccesses += 1
                DispatchQueue.main.async {
                    table?.reloadData()
                }
                DispatchQueue.global(qos: .userInitiated).async {
                    self.manager.remove(obj.path, completition: {
                        obj.loaded = false
                        obj.loading = false
                        self.numberOfProceededProccesses += 1
                        AppDelegate.updateManagers()
                        DispatchQueue.main.async {
                            table?.reloadData()
                        }
                    })
                }
            }
        }
    }
    
    private func readFromServer() {
        guard modules.count == 0, strongs.count == 0, spirit.count == 0 else {return}
        let context = AppDelegate.context
        guard let url = URL(string: AppDelegate.downloadServerURL) else {return}
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil {
                print(error!)
            }
            var allExist = true
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
                            allExist = allExist && exist
                            self.modules.append(DownloadModel(size: size, name: name, loaded: exist, loading: false, path: path))
                        } else if let key = SharingRegex.parseStrong(regex) {
                            let exist = (try? Strong.exists(key, in: context)) ?? false
                            allExist = allExist && exist
                            self.strongs.append(DownloadModel(size: size, name: name, loaded: exist, loading: false, path: path))
                        } else if let key = SharingRegex.parseSpirit(regex) {
                            let exist = SpiritBook.exists(with: key, in: context)
                            allExist = allExist && exist
                            self.spirit.append(DownloadModel(size: size, name: name, loaded: exist, loading: false, path: path))
                        }
                    }
                }
            } else {
                print("No readable data is arrived")
            }
            self.allExists = allExist
            DispatchQueue.main.async {
                self.reloadTables()
                self.refreshControl.isHidden = true
                self.refreshControl.stopAnimation(nil)
                self.downloadAll.title = allExist ? "Remove All" : "Download All"
            }
        }
        task.resume()
    }
    
    private func reloadTables() {
        DispatchQueue.main.async {
            self.tableModule.reloadData()
            self.tableStrongs.reloadData()
            self.tableSpirit.reloadData()
        }
    }
}

extension DownloadViewController: NSTableViewDataSource, NSTableViewDelegate {
    func numberOfRows(in tableView: NSTableView) -> Int {
        if tableView == tableModule {
            return modules.count
        } else if tableView == tableStrongs {
            return strongs.count
        } else if tableView == tableSpirit {
            return spirit.count
        }
        return 0
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier.init(dowlnoadCellViewIdentifier), owner: self)
        
        var selected: DownloadModel
        var index = 0
        if tableView == tableModule {
            selected = modules[row]
        } else if tableView == tableStrongs {
            selected = strongs[row]
            index = 1
        } else if tableView == tableSpirit {
            selected = spirit[row]
            index = 2
        } else {
            return nil
        }

        if let c = cell as? DownloadCellView {
            c.index = (index, row)
            c.left = selected.size
            c.right = selected.name
            c.isLoaded = selected.loaded
            c.loading = selected.loading
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
            _ = index.0 == 0 ? (self.modules[index.1].loaded = success) : index.0 == 1 ? (self.strongs[index.1].loaded = success) : (self.spirit[index.1].loaded = success)
            AppDelegate.updateManagers()
        }
    }
    
    func remove(index: (Int, Int), completition: ((Bool) -> ())?) {
        let selected = index.0 == 0 ? modules[index.1] : index.0 == 1 ? strongs[index.1] : spirit[index.1]
        manager.remove(selected.path) {
            completition?(true)
            AppDelegate.updateManagers()
            
        }
    }
}
