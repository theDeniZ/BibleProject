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
    
    private var modules = [(String, String, Bool, String)]()
    private var strongs = [(String, String, Bool, String)]()
    private var spirit = [(String, String, Bool, String)]()
    private let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        table.dataSource = self
        table.delegate = self
        
        refreshControl.attributedTitle = NSAttributedString(string: "Load data from server")
        refreshControl.addTarget(self, action: #selector(refreshOnDemand(_:)), for: UIControl.Event.valueChanged)
        table.addSubview(refreshControl)
        refreshControl.beginRefreshing()
        readFromServer()
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        readFromServer()
//    }
    
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
                    if let path = file["name"] {
                        let name = String(path[...path.index(path.endIndex, offsetBy: -5)])
                        if let key = SharingRegex.parseModule(name) {
                            let exist = Module.exists(key: key, in: context)
                            self.modules.append((file["size"]!, key, exist, path))
                        } else if let type = SharingRegex.parseStrong(name) {
                            let exist = (try? Strong.exists(type, in: context)) ?? false
                            self.strongs.append((file["size"]!, type, exist, path))
                        }/* else if let code = SharingRegex.parseSpirit(name) {
                            let exist = SpiritBook.exists(with: code, in: context)
                            self.spirit.append((file["size"]!, code, exist, path))
                        }*/ // we are not ready for this
                    }
                }
            } else {
                print("No readable data is arrived")
            }
            DispatchQueue.main.async {
                self.table.reloadData()
                self.refreshControl.endRefreshing()
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
            cell.textLabel?.text = modules[indexPath.row].0
            cell.detailTextLabel?.text = modules[indexPath.row].1
            cell.accessoryType = modules[indexPath.row].2 ? .checkmark : .none
            let label = UILabel(frame: CGRect())
            label.text = modules[indexPath.row].3
            cell.insertSubview(label, at: 0)
        case 1:
            cell.textLabel?.text = strongs[indexPath.row].0
            cell.detailTextLabel?.text = strongs[indexPath.row].1
            cell.accessoryType = strongs[indexPath.row].2 ? .checkmark : .none
            let label = UILabel(frame: CGRect())
            label.text = strongs[indexPath.row].3
            cell.insertSubview(label, at: 0)
        case 2:
            cell.textLabel?.text = spirit[indexPath.row].0
            cell.detailTextLabel?.text = spirit[indexPath.row].1
            cell.accessoryType = spirit[indexPath.row].2 ? .checkmark : .none
            let label = UILabel(frame: CGRect())
            label.text = spirit[indexPath.row].3
            cell.insertSubview(label, at: 0)
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
        let cell = tableView.cellForRow(at: indexPath)
        if cell?.accessoryType == .checkmark {
            // remove
            let text = (cell?.subviews[1] as! UILabel).text!
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
            let text = (cell?.subviews[1] as! UILabel).text!
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
