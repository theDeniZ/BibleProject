//
//  SharedSolutions.swift
//  macB
//
//  Created by Denis Dobanda on 06.03.19.
//  Copyright © 2019 Denis Dobanda. All rights reserved.
//

import Foundation

func getVerseRanges(from array: [String]) -> [Range<Int>] {
    var verseRanges = [Range<Int>]()
    var pendingRange: Range<Int>? = nil
    for verse in array {
        if !("0"..."9" ~= verse[0]) {
            if let v = Int(verse[verse.index(after: verse.startIndex)...]) {
                switch verse[0] {
                case "-":
                    if pendingRange != nil {
                        pendingRange = Range(uncheckedBounds: (pendingRange!.lowerBound, v + 1))
                    } else {
                        pendingRange = Range(uncheckedBounds: (v, v + 1))
                    }
                case ",",".":
                    if pendingRange != nil {
                        verseRanges.append(pendingRange!)
                    }
                    pendingRange = Range(uncheckedBounds: (v, v + 1))
                default:break
                }
            }
        } else {
            let v = Int(verse)!
            if pendingRange != nil {
                verseRanges.append(pendingRange!)
            }
            pendingRange = Range(uncheckedBounds: (v,v + 1))
        }
    }
    if pendingRange != nil {
        verseRanges.append(pendingRange!)
    }
    return verseRanges
}


class PlistHandler {
    
    // MARK: Public API
    var plistPath: String?
    
    func setValue(_ value: Any?, of key: String) {
        if let path = plistPath, let dict = NSMutableDictionary(contentsOfFile: path) {
            dict.setValue(value, forKey: key)
            if (!dict.write(toFile: path, atomically: true)) {
                print("PlistHandler:setValue(\(String(describing: value)), of: \(key) - failing")
                if (!dict.write(toFile: path, atomically: false)) {
                    print("PlistHandler:setValue(\(String(describing: value)), of: \(key) - failed")
                }
            }
        }
    }
    
    // MARK: initializations
    init() {
        plistPath = nil
    }
    
    init(_ path: String?) {
        plistPath = path
    }
}
