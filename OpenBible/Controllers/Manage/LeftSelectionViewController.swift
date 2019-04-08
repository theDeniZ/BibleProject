//
//  ViewController.swift
//  TextViewCustom
//
//  Created by Denis Dobanda on 23.10.18.
//  Copyright © 2018 Denis Dobanda. All rights reserved.
//

import UIKit

class LeftSelectionViewController: UIViewController, Storyboarded {

    var rightSpace: CGFloat = 0.0 {
        didSet {
            rightConstraint.constant = rightSpace
        }
    }
    
    weak var coordinator: MenuCoordinator!
    
    @IBOutlet private weak var moduleButton: UIButton!
    @IBOutlet private weak var rightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var bookTable: UITableView!
    
    private var items: [[ListExpandablePresentable]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let coordinator = coordinator else {return}
        
        rightConstraint.constant = rightSpace
        
        items = coordinator.getItemsToPresent()
        moduleButton?.setTitle(coordinator.getKeysTitle(), for:.normal)
        
        bookTable.dataSource = self
        bookTable.delegate = self
        bookTable.rowHeight = UITableView.automaticDimension
        bookTable.estimatedRowHeight = 36.3
        
        setupButton()
        
        bookTable?.scrollToRow(at: coordinator.selectedBookIndexPath, at:UITableView.ScrollPosition.middle, animated:false)
    }
    
    @IBAction func moduleAction(_ sender: UIButton) {
        coordinator.presentPicker()
    }
    @IBAction func historyAction(_ sender: UIButton) {
        coordinator.presentHistory()
    }
    
    private func setupButton() {
        moduleButton.contentEdgeInsets = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
        moduleButton.clipsToBounds = true
        moduleButton.layer.cornerRadius = moduleButton.frame.height / 2
        moduleButton.layer.borderColor = UIColor.blue.cgColor
        moduleButton.layer.borderWidth = 1.0
    }

}

extension LeftSelectionViewController: BookTableViewCellDelegate {
    func bookTableViewCellDidSelect(chapter: Int, in book: Int) {
        coordinator.didSelect(chapter: chapter, in: book)
    }
}

extension LeftSelectionViewController: ModalDelegate {
    func modalViewWillResign() {
        bookTable?.reloadData()
    }
}

extension LeftSelectionViewController:UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 1 ? 10.0 : 0.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Book Table Cell", for: indexPath)
        if let c = cell as? BookTableViewCell {
            c.item = items[indexPath.section][indexPath.row]
            c.delegate = self
            c.hasZeroElement = items[indexPath.section][indexPath.row].hasZeroElement
        }
        let v = UIView()
        v.backgroundColor = UIColor.white
        cell.selectedBackgroundView = v
        cell.autoresizingMask = .flexibleHeight
        return cell
    }
}

extension LeftSelectionViewController:UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? BookTableViewCell else { return }
        cell.isExpanded = !cell.isExpanded
        cell.setSelected(cell.isExpanded, animated: true)
        tableView.beginUpdates()
        tableView.endUpdates()
        tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? BookTableViewCell else { return }
        cell.isExpanded = false
        tableView.beginUpdates()
        tableView.endUpdates()
    }
}
