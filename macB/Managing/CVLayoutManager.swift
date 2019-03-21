//
//  CVLayoutManager.swift
//  macB
//
//  Created by Denis Dobanda on 17.03.19.
//  Copyright © 2019 Denis Dobanda. All rights reserved.
//

import Cocoa

class CVLayoutManager: NSObject {
    
    var arrayOfVerses = [[NSAttributedString]]() {didSet{cached = []}}
    
    private var cached: [CGFloat?] = []
    private var cachedWidth: CGFloat = 0.0
    
    func calculateHeight(at position: Int, with width: CGFloat) -> CGFloat {
        if cachedWidth != width {
            cachedWidth = width
            cached = []
        }
        if position < cached.count, let cache = cached[position] {return cache}
        var newMax: CGFloat = 0.0
        //        let height: CGFloat = 1000.0
        
        //        let size = CGSize(width: width, height: height)
        for i in 0..<arrayOfVerses.count {
            //            newMax = max(newMax, arrayOfVerses[i][position].boundingRect(with: size, options: .usesLineFragmentOrigin, context: nil).size.height)
            if arrayOfVerses[i].count > position {
                newMax = max(newMax, arrayOfVerses[i][position].sizeFittingWidth(width).height)
            }
        }
        cached.append(newMax)
        return newMax
    }
    
}

