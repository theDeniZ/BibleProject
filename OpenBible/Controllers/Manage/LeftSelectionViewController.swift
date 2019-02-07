//
//  ViewController.swift
//  TextViewCustom
//
//  Created by Denis Dobanda on 23.10.18.
//  Copyright © 2018 Denis Dobanda. All rights reserved.
//

import UIKit

class LeftSelectionViewController: SidePanelViewController {

    
    var manager: Manager! { didSet { updateUI() } }
    var rightSpace: CGFloat = 0.0 {
        didSet {
            rightConstraint.constant = rightSpace
        }
    }
    
    @IBOutlet weak var moduleButton: UIButton!
    private var selectedIndexPath: IndexPath?
    
    @IBOutlet private weak var rightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var bookTable: UITableView!
    
    private var books: [Book]? {
        didSet {
            bookTable?.reloadData()
            var selected = manager.bookNumber - 1
            var section = 0
            if sectionCount != 1, selected >= 39 {
                selected -= 39
                section = 1
            }
            if count == 27 {
                selected -= 39
            }
            bookTable?.scrollToRow(at: IndexPath(row:selected, section:section), at:UITableView.ScrollPosition.middle, animated:false)
            
        }
    }
    
    private var count: Int {
        return books?.count ?? 0
    }
    private var sectionCount: Int {
        return count == 66 ? 2 : 1
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        rightConstraint.constant = rightSpace
        bookTable.dataSource = self
        bookTable.delegate = self
        bookTable.rowHeight = UITableView.automaticDimension
        bookTable.estimatedRowHeight = 36.3
        moduleButton.contentEdgeInsets = UIEdgeInsets(size: 10.0)
        moduleButton.clipsToBounds = true
        moduleButton.layer.cornerRadius = moduleButton.frame.height / 2
        moduleButton.layer.borderColor = UIColor.blue.cgColor
        moduleButton.layer.borderWidth = 1.0
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Show Modal Picker", let dest = segue.destination as? ModalViewController {
            dest.manager = manager
            dest.delegate = self
        } else if segue.identifier == "Show history", let dest = segue.destination as? HistoryViewController {
            dest.delegate = delegate
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUI()
    }
    
    private func updateUI() {
        if let m = manager {
            books = m.getBooks()
            if let modules = manager?.getModulesKey(), var title = modules.0 {
                if let t2 = modules.1 {
                    title.append(" | \(t2)")
                }
                moduleButton?.setTitle(title, for:.normal)
            }
        }
    }

}

extension LeftSelectionViewController:BookTableViewCellDelegate {
    func bookTableViewCellDidSelect(chapter: Int, in book: Int) {
        delegate?.didSelect(chapter: chapter, in:book)
        print("selected \(chapter) in \(book)")
    }
}

extension LeftSelectionViewController:ModalDelegate {
    func modalViewWillResign() {
        bookTable?.reloadData()
        delegate?.setNeedsReload()
    }
}

extension LeftSelectionViewController:UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionCount
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 1 ? 10.0 : 0.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionCount == 1 ? count : section == 0 ? 39 : 27
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Book Table Cell", for: indexPath)
        if let c = cell as? BookTableViewCell, let b = books {
            c.book = b[sectionCount == 1 ? indexPath.row:indexPath.section == 0 ? indexPath.row:39 + indexPath.row]
            c.delegate = self
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
