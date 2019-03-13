//
//  TextCollectionViewCell.swift
//  OpenBible
//
//  Created by Denis Dobanda on 11.03.19.
//  Copyright © 2019 Denis Dobanda. All rights reserved.
//

import UIKit

class TextCollectionViewCell: UICollectionViewCell {
    
    var text: NSAttributedString? {didSet{updateUI()}}
    
    @IBOutlet private weak var mainLabel: UITextView! {didSet{updateUI()}}
    
    private func updateUI() {
        mainLabel?.attributedText = text
    }
    
}
