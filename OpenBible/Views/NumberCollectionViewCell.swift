//
//  NumberCollectionViewCell.swift
//  SplitB
//
//  Created by Denis Dobanda on 29.10.18.
//  Copyright © 2018 Denis Dobanda. All rights reserved.
//

import UIKit

class NumberCollectionViewCell: UICollectionViewCell {
    
    var number: Int = 0 {
        didSet {
            numberLabel?.text = "\(number)"
        }
    }
    
    @IBOutlet private weak var numberLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        numberLabel.text = "\(number)"
    }
    
}
