//
//  BookTableViewCell.swift
//  SplitB
//
//  Created by Denis Dobanda on 29.10.18.
//  Copyright © 2018 Denis Dobanda. All rights reserved.
//

import UIKit

class BookTableViewCell: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    var book: Book! {
        didSet {
            titleLabel?.text = book.name
        }
    }
    var delegate: BookTableViewCellDelegate?
    var bookNumber: Int {
        return Int(book.number)
    }
    
    var isExpanded = false {
        didSet {
            if isExpanded {
                var height = (numbersCollection.bounds.width - (cellsAcross - 1) * spaceBetweenCells) / cellsAcross
                var c = count / Int(cellsAcross)
                if count % Int(cellsAcross) != 0 {
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
    
    private var count: Int { return book.chapters?.array.count ?? 0 }
    private let cellsAcross: CGFloat = 5
    private let spaceBetweenCells: CGFloat = 10
    
    override func awakeFromNib() {
        super.awakeFromNib()
        numbersCollection.isHidden = true
//        titleLabel.text = book.name
        numbersCollection.dataSource = self
        numbersCollection.delegate = self
        sizeToFit()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        numbersCollection.isHidden = !selected
        numbersCollection.sizeToFit()
        numbersCollection.reloadData()
        sizeToFit()
    }
    
    // MARK: - Collection View Delegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.bookTableViewCellDidSelect(chapter: indexPath.row + 1, in:bookNumber)
    }
    
    // MARK: - Collection View Data Source
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let c = collectionView.dequeueReusableCell(withReuseIdentifier: "Number Collection Cell", for: indexPath)
        if let cell = c as? NumberCollectionViewCell {
            cell.number = indexPath.row + 1
        }
        return c
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let dim = (collectionView.bounds.width - (cellsAcross - 1) * spaceBetweenCells) / cellsAcross
        return CGSize(width: dim, height: dim)
    }
}
