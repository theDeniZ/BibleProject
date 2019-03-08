//
//  DownloadVC.swift
//  OpenBible
//
//  Created by Denis Dobanda on 24.02.19.
//  Copyright © 2019 Denis Dobanda. All rights reserved.
//

import UIKit

class DownloadVC: UIViewController {

    @IBOutlet private weak var table: UITableView!
    @IBOutlet weak var allButton: UIButton!
    
    private var modules = [DownloadModel]()
    private var strongs = [DownloadModel]()
    private var spirit = [DownloadModel]()
    private let refreshControl = UIRefreshControl()
    
    private var manager: ConsistencyManager!
    
    private var allExists = false
    private var numberOfBackgroundProccesses = 0
    private var numberOfProceededProccesses = 0 {
        didSet {
            if numberOfProceededProccesses == numberOfBackgroundProccesses {
                numberOfBackgroundProccesses = 0
                numberOfProceededProccesses = 0
                DispatchQueue.main.async {
                    self.allButton.setTitle(self.currentAllButtonTitle, for: .normal)
                    self.allButton.isEnabled = true
                }
            }
        }
    }
    
    private var currentAllButtonTitle: String {
        return allExists ? "Remove All" : "Download All"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        table.dataSource = self
        table.delegate = self
        
        refreshControl.attributedTitle = NSAttributedString(string: "Load data from server")
        refreshControl.addTarget(self, action: #selector(refreshOnDemand(_:)), for: UIControl.Event.valueChanged)
        table.addSubview(refreshControl)
        refreshControl.beginRefreshing()
        readFromServer()
        allButton.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        manager = AppDelegate.shared.consistentManager
    }
    
    @IBAction func allAction(_ sender: UIButton) {
        allButton.isEnabled = false
        if allExists {
            DispatchQueue.global(qos: .userInteractive).async {
                self.removeNeeded(self.modules)
            }
            DispatchQueue.global(qos: .userInteractive).async {
                self.removeNeeded(self.strongs)
            }
//            DispatchQueue.global(qos: .userInteractive).async {
//                self.removeNeeded(self.spirit)
//            }
        } else {
            DispatchQueue.global(qos: .userInteractive).async {
                self.downloadNeeded(self.modules)
            }
            DispatchQueue.global(qos: .userInteractive).async {
                self.downloadNeeded(self.strongs)
            }
//            DispatchQueue.global(qos: .userInteractive).async {
//                self.downloadNeeded(self.spirit)
//            }
        }
        allExists = !allExists
    }
    
    private func downloadNeeded(_ array: [DownloadModel]) {
        for obj in array {
            if !obj.loaded {
                obj.loading = true
                numberOfBackgroundProccesses += 1
                DispatchQueue.main.async {
                    self.manager.download(file: obj.path, completition: { (sucess) in
                        obj.loaded = sucess
                        obj.loading = false
                        self.numberOfProceededProccesses += 1
                        DispatchQueue.main.async {
                            self.table?.reloadData()
                        }
                    })
                }
            }
        }
    }
    
    private func removeNeeded(_ array: [DownloadModel]) {
        for obj in array {
            if obj.loaded {
                obj.loading = true
                numberOfBackgroundProccesses += 1
                DispatchQueue.main.async {
                    self.manager.remove(obj.path, completition: {
                        obj.loaded = false
                        obj.loading = false
                        self.numberOfProceededProccesses += 1
                        DispatchQueue.main.async {
                            self.table?.reloadData()
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
                        }/* else if let key = SharingRegex.parseSpirit(regex) {
                            let exist = SpiritBook.exists(with: key, in: context)
                            self.spirit.append((size, name, exist, path))
                        }*/ // we are not ready for this
                    }
                }
            } else {
                print("No readable data is arrived")
            }
            self.allExists = allExist
            DispatchQueue.main.async {
                self.table.reloadData()
                self.refreshControl.endRefreshing()
                self.allButton.isHidden = false
                self.allButton.setTitle(self.currentAllButtonTitle, for: .normal)
            }
        }
        task.resume()
    }
    
    @objc func refreshOnDemand(_ sender: AnyObject) {
        modules = []
        strongs = []
        spirit = []
        readFromServer()
    }

}

extension DownloadVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return modules.count
        case 1:
            return strongs.count
        case 2:
            return spirit.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Download Cell", for: indexPath)
        switch indexPath.section {
        case 0:
            cell.textLabel?.text = modules[indexPath.row].size
            cell.detailTextLabel?.text = modules[indexPath.row].name
            cell.accessoryType = modules[indexPath.row].loaded ? .checkmark : .none
        case 1:
            cell.textLabel?.text = strongs[indexPath.row].size
            cell.detailTextLabel?.text = strongs[indexPath.row].name
            cell.accessoryType = strongs[indexPath.row].loaded ? .checkmark : .none
        case 2:
            cell.textLabel?.text = spirit[indexPath.row].size
            cell.detailTextLabel?.text = spirit[indexPath.row].name
            cell.accessoryType = spirit[indexPath.row].loaded ? .checkmark : .none
        default: break
        }
        return cell
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Modules"
        case 1:
            return "Strongs"
        case 2:
            return "Spirit"
        default:
            return nil
        }
    }

}

extension DownloadVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selected = indexPath.section == 0 ? modules[indexPath.row] : indexPath.section == 1 ? strongs[indexPath.row] : spirit[indexPath.row]
        let cell = tableView.cellForRow(at: indexPath)
        if cell?.accessoryType == .checkmark {
            // remove
            let text = selected.path
            let alert = UIAlertController(title: "Confirm", message: "Remove \(cell!.detailTextLabel!.text!)?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Remove", style: .default, handler: { (action) in
                print("Removed \(text)")
                AppDelegate.shared.consistentManager.remove(text, completition: {
                    DispatchQueue.main.async {
                        cell?.accessoryType = .none
                    }
                })
            }))
            self.present(alert, animated: true, completion: nil)
        } else {
            // download
            let text = selected.path
            let alert = UIAlertController(title: "Confirm", message: "Download \(cell!.detailTextLabel!.text!)?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Download", style: .default, handler: { (action) in
                print("Download \(text) started")
                AppDelegate.shared.consistentManager.download(file: text, completition: { (downloaded) in
                    DispatchQueue.main.async {
                        cell?.accessoryType = downloaded ? .checkmark : .none
                        if !downloaded {
                            let alertErr = UIAlertController(title: "Error", message: "An unknown error is caught. Please, try again later", preferredStyle: .alert)
                            alertErr.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default, handler: nil))
                            self.present(alertErr, animated: true, completion: nil)
                        }
                    }
                })
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
}
