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
    var index: (Int, Int) = (0,0)
    var delegate: ModelVerseDelegate?
    var presentee: UIPresentee?
    
    @IBOutlet weak var noteButton: UIButton!
    @IBOutlet private weak var mainLabel: UITextView! {didSet{updateUI()}}
    
    override func awakeFromNib() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapped(_:)))
        tapGesture.numberOfTapsRequired = 1
        tapGesture.numberOfTouchesRequired = 1
        tapGesture.cancelsTouchesInView = false
//        addGestureRecognizer(tapGesture)
        mainLabel.addGestureRecognizer(tapGesture)
    }
    
    private func updateUI() {
        mainLabel?.attributedText = text
        noteButton?.isHidden = delegate?.isThereANote(at: index) == nil
    }
    
    @IBAction func noteAction(_ sender: UIButton) {
        presentee?.presentNote(at: index)
    }
    
    @objc private func tapped(_ sender: UITapGestureRecognizer) {
        if mainLabel.selectedRange.length == 0 {
            presentee?.presentMenu(at: index)
        } else {
            mainLabel.selectedRange = NSRange()
        }
    }
}
