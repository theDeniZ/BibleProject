//
//  CVLayoutManager.swift
//  OpenBible
//
//  Created by Denis Dobanda on 11.03.19.
//  Copyright © 2019 Denis Dobanda. All rights reserved.
//

import UIKit

class CVLayoutManager: NSObject {
    
    var presentable = CollectionPresentable() {didSet{cached = [:]}}
    
    private var cached: [Int: [Int: CGFloat]] = [:]
    private var cachedWidth: CGFloat = 0.0
    
    func calculateHeight(at indexPath: IndexPath, with width: CGFloat) -> CGFloat {
        
        let count = presentable.countOfInternalColumns(in: indexPath.section)
        let row = indexPath.row / count
        
        if cachedWidth != width {
            cachedWidth = width
            cached = [:]
        }
        if let cache = cached[indexPath.section]?[row] {
            return cache
        }
        var newMax: CGFloat = 0.0
        
        for i in 0..<presentable.sections[indexPath.section].presentable.count {
//            newMax = max(newMax, arrayOfVerses[i][position].boundingRect(with: size, options: .usesLineFragmentOrigin, context: nil).size.height)
            if presentable.sections[indexPath.section].presentable[i].count > row {
                newMax = max(newMax, presentable.sections[indexPath.section].presentable[i][row].attributedString.sizeFittingWidth(width).height)
            }
        }
        if cached[indexPath.section] == nil {
            cached[indexPath.section] = [:]
        }
        cached[indexPath.section]?[row] = newMax
        return newMax
    }
    
}
