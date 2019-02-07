//
//  ModalViewController.swift
//  SplitB
//
//  Created by Denis Dobanda on 29.10.18.
//  Copyright © 2018 Denis Dobanda. All rights reserved.
//

import UIKit

class ModalViewController: UIViewController {

    var manager: Manager?
    var delegate: ModalDelegate?
    var modules: [Module]? {
        return manager?.getAvailableModules()
    }
    
    private var selectedModulesKey: [String]? {
        if let m = manager, let first = m.getMainModuleKey() {
            if let sec = m.getSecondaryModuleKey() {
                return [first, sec]
            } else {
                return [first]
            }
        }
        return nil
    }
    
    private var selectedIndexes: [IndexPath] = []
    
    @IBOutlet private weak var table: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        table.delegate = self
        table.dataSource = self
    }

    @IBAction func closeButton(_ sender: Any) {
        delegate?.modalViewWillResign()
        dismiss(animated: true, completion: nil)
    }
    
}

extension ModalViewController:UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let m = manager, let modules = modules {
            if selectedIndexes.contains(indexPath), selectedIndexes.count > 1 {
                if selectedIndexes[0] == indexPath {
                    m.setFirst(modules[selectedIndexes[1].row])
                    m.setSecond(nil)
                    tableView.reloadRows(at: [selectedIndexes[0]], with: .automatic)
                    selectedIndexes.remove(at: 0)
                } else {
                    m.setSecond(nil)
                    tableView.reloadRows(at: [selectedIndexes[1]], with: .automatic)
                    selectedIndexes.remove(at: 1)
                }
            } else {
                if selectedIndexes.count == 1 {
                    selectedIndexes.append(indexPath)
                    m.setSecond(modules[indexPath.row])
                } else {
                    m.setSecond(modules[indexPath.row])
                    tableView.reloadRows(at: [selectedIndexes[1]], with: .automatic)
                    selectedIndexes[1] = indexPath
                }
            }
        }
        print(selectedIndexes)
        tableView.reloadRows(at: selectedIndexes, with: .automatic)
    }
}

extension ModalViewController:UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return modules?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Modal Table Cell", for: indexPath)
        if let m = modules {
            cell.detailTextLabel?.text = m[indexPath.row].name
            cell.textLabel?.text = m[indexPath.row].key
            cell.accessoryType = .none
            if let selected = selectedModulesKey,
                let k = m[indexPath.row].key,
                selected.contains(k) {
                cell.accessoryType = .checkmark
                if !selectedIndexes.contains(indexPath) {
                    if selected[0] == k {
                        selectedIndexes.insert(indexPath, at: 0)
                    } else {
                        selectedIndexes.append(indexPath)
                    }
                }
            }
        }
        return cell
    }
    
}
