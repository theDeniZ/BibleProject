//
//  SharedExtensions.swift
//  macB
//
//  Created by Denis Dobanda on 06.03.19.
//  Copyright © 2019 Denis Dobanda. All rights reserved.
//

import Foundation

extension String {
    static let regexForBookRefference = "^((?:\\d*\\s*)(?:\\w+[^0-9:.,]))\\s*(\\d+)?(?:\\s*[:,]?\\s*(\\d+)(\\s*[,.-]?\\s*(\\d+))*)?"
    static let regexForVerses = "(?!^)((?:[,.-])?\\d+)"
    static let regexForVersesOnly = "((?:[,.-])?\\d+)"
    static let regexForSpiritIndex = "\\[?(\\w+[^:])(:)?(\\d+)\\]?"
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
    
    func index(_ number: String.IndexDistance) -> String.Index {
        return index(startIndex, offsetBy: number)
    }
    
    subscript(num: Int) -> Character {
        return self[index(num)]
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
