//
//  SearchTableViewCell.swift
//  OpenBible
//
//  Created by Denis Dobanda on 06.03.19.
//  Copyright © 2019 Denis Dobanda. All rights reserved.
//

import UIKit

class SearchTableViewCell: UITableViewCell {

    var title: String? { didSet { updateUI() } }
    var textToShow: String? { didSet { updateUI() } }
    
    @IBOutlet private weak var titleLabel: UILabel! { didSet { updateUI() } }
    @IBOutlet private weak var mainTextLabel: UILabel! { didSet { updateUI() } }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        updateUI()
    }
    
    private func updateUI() {
        titleLabel?.text = title
        mainTextLabel?.text = textToShow
    }

}
