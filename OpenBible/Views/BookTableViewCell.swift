//
//  BookTableViewCell.swift
//  SplitB
//
//  Created by Denis Dobanda on 29.10.18.
//  Copyright © 2018 Denis Dobanda. All rights reserved.
//

import UIKit

class BookTableViewCell: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var item: ListExpandablePresentable! {
        didSet {
            titleLabel?.text = item.title
        }
    }
    var delegate: BookTableViewCellDelegate?
    var hasZeroElement: Bool = false
    
    var isExpanded = false {
        didSet {
            if isExpanded {
                var height = (numbersCollection.bounds.width - CGFloat(cellsAcross - 1) * spaceBetweenCells) / CGFloat(cellsAcross)
                var c = item.countOfExpandable / Int(cellsAcross)
                if item.countOfExpandable % Int(cellsAcross) != 0 {
                    c += 1
                }
                height *= CGFloat(c)
                height += spaceBetweenCells * CGFloat(c - 1)
                collectionViewHeight.constant = height
            } else {
                collectionViewHeight.constant = 0.0
            }
            
        }
    }
    
    
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var numbersCollection: UICollectionView!
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!
    
    private var cellsAcross: Int = 5
    private let spaceBetweenCells: CGFloat = 10
    private let maximalCellSize: CGFloat = 48.0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        numbersCollection.isHidden = true
//        titleLabel.text = item.title
        numbersCollection.dataSource = self
        numbersCollection.delegate = self
        sizeToFit()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        cellsAcross = Int(floor(bounds.width / maximalCellSize))
        numbersCollection.isHidden = !selected
        numbersCollection.sizeToFit()
        numbersCollection.reloadData()
        sizeToFit()
    }
    
    // MARK: - Collection View Delegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.bookTableViewCellDidSelect(chapter: indexPath.row + 1, in: item.index)
    }
    
    // MARK: - Collection View Data Source
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return item.countOfExpandable + (hasZeroElement ? 1 : 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let c = collectionView.dequeueReusableCell(withReuseIdentifier: "Number Collection Cell", for: indexPath)
        if let cell = c as? NumberCollectionViewCell {
            cell.number = indexPath.row + (hasZeroElement ? 0 : 1)
        }
        return c
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let dim = (collectionView.bounds.width - CGFloat(cellsAcross - 1) * spaceBetweenCells) / CGFloat(cellsAcross)
        return CGSize(width: dim, height: dim)
    }
}
