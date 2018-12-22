//
//  Extensions.swift
//  SplitB
//
//  Created by Denis Dobanda on 28.10.18.
//  Copyright © 2018 Denis Dobanda. All rights reserved.
//

import Cocoa

extension CGRect {
    init(_ x: Double, _ y: Double, _ width: Double, _ height: Double) {
        self.init(x: x, y: y, width: width, height: height)
    }
    init(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) {
        self.init(x: x, y: y, width: width, height: height)
    }
    init(_ x: Int, _ y: Int, _ width: Int, _ height: Int) {
        self.init(x: x, y: y, width: width, height: height)
    }
    
    init(_ fir: CGPoint, _ sec: CGPoint) {
        self.init(origin:CGPoint(x:min(fir.x, sec.x), y:min(fir.y, sec.y)), size:CGSize(width:abs(fir.x - sec.x), height:abs(fir.y - sec.y)))
    }
    init(bounding first: CGRect, with second: CGRect) {
        let fX = first.origin.x
        let fY = first.origin.y
        let sX = second.origin.x
        let sY = second.origin.y
        let minX = min(fX, sX)
        let minY = min(fY, sY)
        
        let lfX = fX + first.width
        let lfY = fY + first.height
        let lsX = sX + second.width
        let lsY = sY + second.height
        
        let w = max(lfX - minX, lsX - minX)
        let h = max(lfY - minY, lsY - minY)
        self.init(minX, minY, w, h)
    }
    
    static func +(lhs: CGRect, rhs: CGRect ) -> CGRect {
        var rect = lhs
        rect.origin.y = rhs.origin.y + rhs.size.height
        return rect
    }
    static func -(lhs: CGRect, rhs: CGRect ) -> CGRect {
        var rect = lhs
        rect.origin.y = rhs.origin.y - lhs.size.height
        return rect
    }
    
    var bottomRightEdge: CGPoint {
        return CGPoint(x: origin.x + width, y: origin.y + height)
    }
    
    var bottomLeftEdge: CGPoint {
        return CGPoint(x: origin.x, y: maxY)
    }
}


extension String {
    
    static let regexForBookRefference = "((?:\\d*\\s*)(?:[A-z]+))\\s*(\\d+)\\s*[:,]?\\s*(\\d+)(\\s*[,.-]?\\s*(\\d+))*"
    
    func indicesOf(string: String) -> [Int] {
        var indices = [Int]()
        var searchStartIndex = self.startIndex
        
        while searchStartIndex < self.endIndex,
            let range = self.range(of: string, range: searchStartIndex..<self.endIndex),
            !range.isEmpty
        {
            let index = distance(from: self.startIndex, to: range.lowerBound)
            indices.append(index)
            searchStartIndex = range.upperBound
        }
        
        return indices
    }
    
    func ranging(from range: Range<Int> ) -> Range<String.Index> {
        return self.index(startIndex, offsetBy: range.lowerBound)..<self.index(startIndex, offsetBy: range.upperBound)
    }
    
    func index(_ number: String.IndexDistance) -> String.Index {
        return index(startIndex, offsetBy: number)
    }
    
    subscript(n: Int) -> Character {
        return self[index(n)]
    }
    
    subscript (bounds: CountableClosedRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start...end])
    }
    
    subscript (bounds: CountableRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start..<end])
    }
    
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
    
    
    func capturedGroups(withRegex pattern: String) -> [String]? {
        var regex: NSRegularExpression
        do {
            regex = try NSRegularExpression(pattern: pattern, options: [])
        } catch {
            return nil
        }
        
        let matches = regex.matches(in: self, options: [], range: NSRange(location:0, length: self.count))
        
        guard let match = matches.first else { return nil }
        
        // Note: Index 1 is 1st capture group, 2 is 2nd, ..., while index 0 is full match which we don't use
        let lastRangeIndex = match.numberOfRanges - 1
        guard lastRangeIndex >= 1 else { return nil }
        
        var results = [String]()
        
        for i in 1...lastRangeIndex {
            let capturedGroupIndex = match.range(at: i)
            if capturedGroupIndex.length > 0 {
                let matchedString = (self as NSString).substring(with: capturedGroupIndex)
                results.append(matchedString)
            }
        }
        
        return results
    }
}

extension Range where Bound: FixedWidthInteger {
    var nsRange: NSRange { return NSRange(self) }
}
