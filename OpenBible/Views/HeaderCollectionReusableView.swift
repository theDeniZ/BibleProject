//
//  HeaderCollectionReusableView.swift
//  OpenBible
//
//  Created by Denis Dobanda on 07.07.19.
//  Copyright © 2019 Denis Dobanda. All rights reserved.
//

import UIKit

class HeaderCollectionReusableView: UICollectionReusableView {
    
    var header: String? { didSet { updateUI() } }
    
    @IBOutlet weak var headerLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        updateUI()
    }
    
    private func updateUI() {
        headerLabel?.text = header
    }
    
}
