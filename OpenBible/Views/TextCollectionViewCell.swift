//
//  TextCollectionViewCell.swift
//  OpenBible
//
//  Created by Denis Dobanda on 11.03.19.
//  Copyright © 2019 Denis Dobanda. All rights reserved.
//

import UIKit

class TextCollectionViewCell: UICollectionViewCell {
    
//    var text: NSAttributedString? {didSet{updateUI()}}
    var presented: Presentable? {didSet{updateUI()}}
    var index: Int = 0
//    var delegate: ModelVerseDelegate? {didSet{updateUI()}}
    var presentee: UIPresentee?
    
    @IBOutlet weak var noteButton: UIButton!
    @IBOutlet private weak var mainLabel: UITextView!
    
    override func awakeFromNib() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapped(_:)))
        tapGesture.numberOfTapsRequired = 1
        tapGesture.numberOfTouchesRequired = 1
        tapGesture.cancelsTouchesInView = false
//        addGestureRecognizer(tapGesture)
        if let gs = mainLabel.gestureRecognizers {
            for gesture in gs {
                if let b = gesture.name?.contains("Link"), b {
                    tapGesture.require(toFail: gesture)
                } else if let b = gesture.name?.contains("SingleTap"), b {
                    gesture.require(toFail: tapGesture)
                }
            }
        }
        mainLabel.addGestureRecognizer(tapGesture)
    }
    
    private func updateUI() {
        guard let presented = presented else {
            mainLabel?.text = ""
            noteButton?.isHidden = true
            mainLabel.layer.backgroundColor = nil
            return
        }
        mainLabel?.attributedText = presented.attributedString
        noteButton?.isHidden = !presented.hasNote
        mainLabel.layer.backgroundColor = nil
    }
    
    @IBAction func noteAction(_ sender: UIButton) {
        guard let presented = presented else {return}
        presentee?.presentNote(at: (index, presented.index))
    }
    
    @objc private func tapped(_ sender: UITapGestureRecognizer) {
        guard let presented = presented else {return}
        if mainLabel.selectedRange.length == 0 {
//            let pos = sender.location(in: mainLabel)
//            let idx = mainLabel.layoutManager.glyphIndex(for: pos, in: mainLabel.textContainer)
//            if mainLabel.attributedText.attribute(.link, at: idx, effectiveRange: nil) != nil {
//                return
//            }
            presentee?.presentMenu(at: (index, presented.index))
            select()
        } else {
//            mainLabel.selectedRange = NSRange()
            sender.state = .failed
        }
    }
    
    private func select() {
//        mainLabel.selectedRange = NSRange(0..<mainLabel.text.count)
//        mainLabel.selectAll(nil)
        mainLabel.layer.backgroundColor = UIColor.gray.withAlphaComponent(0.6).cgColor
    }
}
