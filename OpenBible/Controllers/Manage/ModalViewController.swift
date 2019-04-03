//
//  ModalViewController.swift
//  SplitB
//
//  Created by Denis Dobanda on 29.10.18.
//  Copyright © 2018 Denis Dobanda. All rights reserved.
//

import UIKit

class ModalViewController: UIViewController, Storyboarded {
//
//    var manager: VerseManager?
//    var delegate: ModalDelegate?
//
    private var modules: [(String, String)]?
    private var selectedModules: [(String, String)]?
    
    weak var coordinator: MainModalCoordinator!

    @IBOutlet private weak var table: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        modules = coordinator.getNotSelectedModules()
        selectedModules = coordinator.getSelectedModules()
        table.delegate = self
        table.dataSource = self
        table.setEditing(true, animated: true)
        if UIDevice.current.userInterfaceIdiom == .phone {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(close))
        } else {
            navigationController?.isNavigationBarHidden = true
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        coordinator.dismiss()
    }
    
    @objc private func close() {
        dismiss(animated: false, completion: nil)
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
                coordinator.insert(module, at: destinationIndexPath.row)
            } else {
                modules!.insert(selectedModules![sourceIndexPath.row], at: destinationIndexPath.row)
                selectedModules?.remove(at: sourceIndexPath.row)
                coordinator.removeModule(at: sourceIndexPath.row)
            }
        } else {
            if sourceIndexPath.section == 0 {
                selectedModules?.swapAt(sourceIndexPath.row, destinationIndexPath.row)
                coordinator.swapModulesAt(sourceIndexPath.row, destinationIndexPath.row)
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
        var module: (key: String, name: String)
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
