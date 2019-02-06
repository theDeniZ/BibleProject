//
//  DownloadCell.swift
//  SplitB
//
//  Created by Denis Dobanda on 17.12.18.
//  Copyright © 2018 Denis Dobanda. All rights reserved.
//

import UIKit

class DownloadCell: UITableViewCell {

    var isLoading: Bool = false { didSet {animate()}}
    var left: String? { didSet {updateUI()}}
    var right: String? { didSet {updateUI()}}
    var columnWidth: CGFloat = 0 { didSet {updateUI()}}
    
    @IBOutlet private weak var leftLabel: UILabel!
    @IBOutlet private weak var rightLabel: UILabel!
    @IBOutlet private weak var activity: UIActivityIndicatorView!
    @IBOutlet private weak var leftConstraint: NSLayoutConstraint!
    
    private func updateUI() {
        leftLabel?.text = left
        rightLabel?.text = right
        leftConstraint?.constant = columnWidth
    }
    
    private func animate() {
        if isLoading {
            activity.isHidden = false
            activity.startAnimating()
        } else {
            activity.isHidden = true
            activity.stopAnimating()
        }
    }
}
