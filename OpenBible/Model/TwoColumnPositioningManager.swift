//
//  TwoColumnPositioningManager.swift
//  SplitB
//
//  Created by Denis Dobanda on 25.10.18.
//  Copyright © 2018 Denis Dobanda. All rights reserved.
//

import UIKit

class TwoColumnPositioningManager {

    var size: CGSize
    var ranges: [Range <Int>]
    var dividers: [Int]
    var height: CGFloat
    
    private var current1 = 0
    private var current2 = 0
    
    private var origin1: CGPoint
    private var origin2: CGPoint
    
    private var columnWidth: CGFloat { get { return size.width / 2 } }
    private var fullWidth: CGFloat { get { return size.width } }
    private var rectSize: CGSize { return CGSize(width: columnWidth, height: height) }
    private var dividerSize: CGSize { return CGSize(width: fullWidth, height: height / 10.0) }
    private var fullSize: CGSize { return CGSize(width: fullWidth, height: height) }
    
    init(_ size: CGSize, ranges: [Range<Int>], dividers: [Int], height: CGFloat) {
        self.size = size
        self.ranges = ranges
        self.dividers = dividers
        self.height = height
        origin1 = CGPoint(x: 0, y: 0)
        origin2 = CGPoint(x: size.width / 2, y: 0)
    }
    
    func getRect(for characterNumber: Int, prefferedHeight: CGFloat) -> CGRect {
        if characterNumber == 0 {
            origin1 = CGPoint(x: 0, y: 0)
            origin2 = CGPoint(x: size.width / 2, y: 0)
            current1 = 0
            current2 = 0
        }
        if height < 0.1 {
            height = prefferedHeight
        }
        
        if isDivider(characterNumber) {
            if current1 < current2 {
                origin1.match(origin2)
            }
            let result = CGRect(origin: origin1, size: dividerSize)
            origin1 = origin1 + (height / 10)
            origin2.match(origin1)
            current2 = 0
            current1 = 0
            return result
        } else if ranges.count == 0 {
            let result = CGRect(origin: origin1, size: fullSize)
            origin1 = origin1 + height
            origin2 = origin2 + height
            return result
        } else if isInRange(characterNumber) {
            let result = CGRect(origin: origin2, size: rectSize)
            origin2 = origin2 + height
            current2 += 1
            return result
        } else {
            let result = CGRect(origin: origin1, size: rectSize)
            origin1 = origin1 + height
            current1 += 1
            return result
        }
    }
    
    private func isInRange(_ number: Int) -> Bool {
        var index = 0
        while index < ranges.count {
            if ranges[index].contains(number) {
                return true
            } else if ranges[index].lowerBound > number {
                return false
            }
            index += 1
        }
        return false
    }
    
    private func isDivider(_ number: Int) -> Bool {
        return dividers.contains(number)
    }
    
    
}


extension CGRect:Comparable {
    public static func <(lhs: CGRect, rhs: CGRect) -> Bool {
        return lhs.origin.y < rhs.origin.y
    }
}

extension CGPoint {
    static func +(lhs: CGPoint, num: CGFloat) -> CGPoint {
        var p = lhs
        p.y += num
        return p
    }
    
    mutating func match(_ point: CGPoint) {
        self.y = point.y
    }
}
