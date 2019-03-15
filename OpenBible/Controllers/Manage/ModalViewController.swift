//
//  ModalViewController.swift
//  SplitB
//
//  Created by Denis Dobanda on 29.10.18.
//  Copyright © 2018 Denis Dobanda. All rights reserved.
//

import UIKit

class ModalViewController: UIViewController {

    var manager: VerseManager?
    var delegate: ModalDelegate?
    
    private var modules: [Module]?
    private var selectedModules: [Module]?

    @IBOutlet private weak var table: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        modules = manager?.getAllAvailableModules()
        selectedModules = manager?.modules
        table.delegate = self
        table.dataSource = self
        table.setEditing(true, animated: true)
    }

    @IBAction func closeButton(_ sender: Any) {
        delegate?.modalViewWillResign()
        dismiss(animated: true, completion: nil)
    }
    
}

extension ModalViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        if sourceIndexPath.section != destinationIndexPath.section {
            if sourceIndexPath.section != 0 {
                let module = modules![sourceIndexPath.row]
                modules!.remove(at: sourceIndexPath.row)
                selectedModules!.insert(module, at: destinationIndexPath.row)
                manager!.insert(module, at: destinationIndexPath.row)
            } else {
                modules!.insert(selectedModules![sourceIndexPath.row], at: destinationIndexPath.row)
                selectedModules?.remove(at: sourceIndexPath.row)
                manager!.removeModule(at: sourceIndexPath.row)
            }
        } else {
            if sourceIndexPath.section == 0 {
                selectedModules?.swapAt(sourceIndexPath.row, destinationIndexPath.row)
                manager!.swapModulesAt(sourceIndexPath.row, destinationIndexPath.row)
            } else {
                modules?.swapAt(sourceIndexPath.row, destinationIndexPath.row)
            }
        }
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 0, selectedModules?.count == 1 {return false}
        return true
    }
}

extension ModalViewController:UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Present"
        default:
            return "Hide"
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? selectedModules?.count ?? 0 : modules?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Modal Table Cell", for: indexPath)
        var module: Module
        if indexPath.section == 0 {
            module = selectedModules![indexPath.row]
        } else {
            module = modules![indexPath.row]
        }
        
        cell.detailTextLabel?.text = module.name
        cell.textLabel?.text = module.key
        
        return cell
    }
    
}
