//
//  Extensions.swift
//  SplitB
//
//  Created by Denis Dobanda on 28.10.18.
//  Copyright © 2018 Denis Dobanda. All rights reserved.
//

import UIKit

struct StrongIdentifier {
    static let oldTestament = "Hebrew"
    static let newTestament = "Greek"
    static let plistIdentifier = "strong_keys"
}

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
}


extension String {
    
    static let regexForBookRefference = "((?:\\d*\\s*)(?:\\w+[^0-9:.,-]))\\s*(\\d+)(?:\\s*[:,]?\\s*(\\d+)(\\s*[,.-]?\\s*(\\d+))*)?"
    static let regexForVerses = "((?:[,.-])?\\d+)"
    static let regexForChapter = "^(\\d+)$"
    
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
    
    func matches(withRegex pattern: String) -> [[String]]? {
        var regex: NSRegularExpression
        do {
            regex = try NSRegularExpression(pattern: pattern, options: [])
        } catch {
            return nil
        }
        
        let matches = regex.matches(in: self, options: [], range: NSRange(location:0, length: self.count))
        guard matches.count > 0 else { return nil }
        
        var returning = [[String]]()
        for match in matches {
            // Note: Index 1 is 1st capture group, 2 is 2nd, ..., while index 0 is full match which we don't use
            let lastRangeIndex = match.numberOfRanges - 1
            if lastRangeIndex >= 1 {
                var results = [String]()
                for i in 1...lastRangeIndex {
                    let capturedGroupIndex = match.range(at: i)
                    if capturedGroupIndex.length > 0 {
                        let matchedString = (self as NSString).substring(with: capturedGroupIndex)
                        results.append(matchedString)
                    }
                }
                returning.append(results)
            }
        }
        return returning
    }
    
    func matches(_ pattern: String) -> Bool {
        var regex: NSRegularExpression
        do {
            regex = try NSRegularExpression(pattern: pattern, options: [])
        } catch {
            return false
        }
        
        let matches = regex.matches(in: self, options: [], range: NSRange(location:0, length: self.count))
        return matches.count > 0
    }
}

extension UIEdgeInsets {
    init(size: CGFloat) {
        self.init(top: size, left: size, bottom: size, right: size)
    }
}

extension Range where Bound: FixedWidthInteger {
    var nsRange: NSRange { return NSRange(self) }
}

extension NSAttributedString: StrongsLinkEmbeddable {
    var strongNumbersAvailable: Bool {
        return self.string.matches("( \\d+ )")
    }
    
    func embedStrongs(to link: String, using size: CGFloat, linking: Bool = true) -> NSAttributedString {
        let newMAString = NSMutableAttributedString(string: " ", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: size)])
//        var colorAttribute: [NSAttributedString.Key: Any]?
        let upperAttribute: [NSAttributedString.Key: Any] =
            [NSAttributedString.Key.baselineOffset : size * 0.333,
             NSAttributedString.Key.font : UIFont.systemFont(ofSize: size * 0.666)]
        
//        if let c = NSColor(named: NSColor.Name("textColor")) {
//            colorAttribute = [NSAttributedString.Key.foregroundColor : c]
//            upperAttribute[NSAttributedString.Key.foregroundColor] = c
//        }
        let splited = string.replacingOccurrences(of: "\r\n", with: "").split(separator: " ").map {String($0)}
        newMAString.append(NSAttributedString(string: splited[0] + " ", attributes: upperAttribute))
        var i = 1
        while i < splited.count {
            if !splited[i].matches("\\d+") {
                let s = NSMutableAttributedString(string: splited[i])
                var numbers: [Int] = []
                while i < splited.count - 1, splited[i + 1].matches("\\d+") {
                    i += 1
                    let numberStr = splited[i].capturedGroups(withRegex: "(\\d+)")![0]
                    numbers.append(Int(numberStr)!)
                    if splited[i].count != numberStr.count {
                        s.append(NSAttributedString(string: splited[i].replacingOccurrences(of: numberStr, with: "")))
                    }
                }
                s.append(NSAttributedString(string: " "))
//                if let c = colorAttribute {
//                    s.addAttributes(c, range: NSRange(0..<s.length))
//                }
                if linking, numbers.count > 0 {
                    let url = link + numbers.map({String($0)}).joined(separator: "+")
                    s.addAttribute(NSAttributedString.Key.link, value: url, range: NSRange(0..<s.length - 1))
                    //                    s.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single, range: NSRange(0..<s.length - 1))
                }
                s.addAttributes([.font: UIFont.systemFont(ofSize: size)], range: NSRange(0..<s.length))
                newMAString.append(s)
            }
            i += 1
        }
//        if !newMAString.string.hasSuffix("\n ") {
            newMAString.append(NSAttributedString(string: "\r\n"))
//        }
        return newMAString
    }
    
    
}

extension Data {
    static func from(chunks: [Data]) -> Data {
        var d = Data()
        for data in chunks {
            d.append(data)
        }
        return d
    }
}
