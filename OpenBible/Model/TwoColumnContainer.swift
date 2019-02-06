//
//  File.swift
//  TextViewCustom
//
//  Created by Denis Dobanda on 24.10.18.
//  Copyright © 2018 Denis Dobanda. All rights reserved.
//

import UIKit

class TwoColumnContainer: NSTextContainer {
    
//    static var count: Int = 0
//
//    var rangesForSecond: [Range<Int>]?
//    var dividers: [Int]?
//
//    private var countOfLinesFirst = 0
//    private var countOfLinesSecond = 0
//    private var switchColumn = 1
//    private var lastHeight: CGFloat = 0.0
//
    var manager: TwoColumnPositioningManager?
    
    override var isSimpleRectangularTextContainer: Bool {return false}
    
    override func lineFragmentRect(forProposedRect proposedRect: CGRect, at characterIndex: Int, writingDirection baseWritingDirection: NSWritingDirection, remaining remainingRect: UnsafeMutablePointer<CGRect>?) -> CGRect {
        
        let result = super.lineFragmentRect(forProposedRect: proposedRect, at: characterIndex, writingDirection: baseWritingDirection, remaining: remainingRect)
        
        if let m = manager {
            return m.getRect(for: characterIndex, prefferedHeight: result.height)
        }
        print("not \(result)")
        return result
        
        
//        if characterIndex == 0 {
//            print("How many times... \(TwoColumnContainer.count), \(remainingRect)")
//            TwoColumnContainer.count += 1
//            countOfLinesFirst = 0
//            countOfLinesSecond = 0
//            switchColumn = 1
//            lastHeight = 0.0
//        }
//
//
//        if let div = dividers, div.contains(characterIndex) {
//            //                print("founded divider at \(characterIndex),\n returning \(result)")
//            if switchColumn == 2, countOfLinesFirst > countOfLinesSecond {
//                let diff = countOfLinesFirst - countOfLinesSecond
//                //                    result.origin.x += result.size.width
//                result.origin.y += lastHeight * CGFloat(diff)
//                switchColumn = 1
//            }
//            countOfLinesSecond = 0
//            countOfLinesFirst = 0
//            print("Div \nret\(result)\npro\(proposedRect), \(characterIndex)")
//            return result
//        }
//
//        if let ranges = rangesForSecond {
//
//            result.size.width /= 2
//
//            var searching = true
//            var founded = false
//            var index = 0
//            while searching && index < ranges.count {
//                if ranges[index].contains(characterIndex) {
//                    searching = false
//                    founded = true
//                } else if ranges[index].lowerBound > characterIndex {
//                    searching = false
//                }
//                index += 1
//            }
//
//            if founded {
//                if switchColumn == 1 {
//                    let diff = countOfLinesFirst - countOfLinesSecond
//                    result.origin.x += result.size.width
//                    result.origin.y -= result.size.height * CGFloat(diff)
//                    switchColumn = 2
//                } else {
//                    result.origin.x += result.size.width
//                }
//                countOfLinesSecond += 1
//            } else {
//                switchColumn = 1
//                countOfLinesFirst += 1
//            }
//
//        }
//
//        lastHeight = result.height
//        print("Norm \nret\(result)\npro\(proposedRect), \(characterIndex)")
//        return result
    }
}
