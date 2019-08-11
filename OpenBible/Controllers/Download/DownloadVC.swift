//
//  DownloadVC.swift
//  OpenBible
//
//  Created by Denis Dobanda on 24.02.19.
//  Copyright © 2019 Denis Dobanda. All rights reserved.
//

import UIKit

class DownloadVC: UIViewController, Storyboarded {

    weak var coordinator: DownloadCoordinator?
    
    @IBOutlet private weak var table: UITableView!
    @IBOutlet private weak var allButton: UIButton!
    
    private var modules: [DownloadModel] {return coordinator?.modules ?? []}
    private var strongs: [DownloadModel] {return coordinator?.strongs ?? []}
    private var spirit: [DownloadModel] {return coordinator?.spirit ?? []}
    
    private let refreshControl = UIRefreshControl()
    
//    private var manager: ConsistencyManager!
    
    private var allExists: Bool {return coordinator?.allExists ?? false}
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
//        table.dataSource = self
//        table.delegate = self
        
        refreshControl.attributedTitle = NSAttributedString(string: "Load data from server")
        refreshControl.addTarget(self, action: #selector(refreshOnDemand(_:)), for: UIControl.Event.valueChanged)
        table.addSubview(refreshControl)
        refreshControl.beginRefreshing()
        allButton.isHidden = true
        
        coordinator?.readFromServer() {
            self.updateUI()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        manager = AppDelegate.shared.consistentManager
    }
    
    @IBAction func allAction(_ sender: UIButton) {
        let message = allExists ? "Remove all?" : "Download all?"
        let alert = UIAlertController.init(title: "Confirm", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Yes", style: allExists ? .destructive : .default, handler: { (action) in
            self.doAllAction()
        }))
        present(alert, animated: true, completion: nil)
    }
    
    private func doAllAction() {
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
    }
    
    private func downloadNeeded(_ array: [DownloadModel]) {
        for obj in array {
            if !obj.loaded {
                obj.loading = true
                numberOfBackgroundProccesses += 1
                DispatchQueue.main.async {
                    self.coordinator?.download(obj.path, completition: { (sucess) in
                        obj.loaded = sucess
                        obj.loading = false
                        self.numberOfProceededProccesses += 1
                        DispatchQueue.main.async {
                            self.table?.reloadData()
                            self.allButton.setTitle(self.currentAllButtonTitle, for: .normal)
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
                    self.coordinator?.remove(obj.path, completition: {
                        obj.loaded = false
                        obj.loading = false
                        self.numberOfProceededProccesses += 1
                        DispatchQueue.main.async {
                            self.table?.reloadData()
                            self.allButton.setTitle(self.currentAllButtonTitle, for: .normal)
                        }
                    })
                }
            }
        }
    }
    
    private func updateUI() {
        DispatchQueue.main.async {
            self.table.reloadData()
            self.refreshControl.endRefreshing()
            self.allButton.isHidden = false
            self.allButton.setTitle(self.currentAllButtonTitle, for: .normal)
        }
    }
    
    @objc func refreshOnDemand(_ sender: AnyObject) {
        coordinator?.readFromServer() {
            self.updateUI()
        }
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
        return 2
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
