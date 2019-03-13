//
//  VerseManager.swift
//  SplitB
//
//  Created by Denis Dobanda on 22.11.18.
//  Copyright © 2018 Denis Dobanda. All rights reserved.
//

import UIKit
import CoreData

class VerseManager: CoreManager {

    var fontSize: CGFloat
    
    override init(_ context: NSManagedObjectContext) {
        fontSize = AppDelegate.plistManager.getFontSize()
        super.init(context)
    }
    
    override func getAttributedString(from index: Int, loadingTooltip: Bool) -> [NSAttributedString] {
        if let chapter = chapter(index) {
            if let vrss = chapter.verses?.array as? [Verse] {
                if let vs = verses {
                    var result = [NSAttributedString]()
                    for range in vs {
                        let versesFiltered = vrss.filter {range.contains(Int($0.number))}
                        for verse in versesFiltered {
                            let attributedVerse = verse.attributedCompound(size: fontSize)
                            //check for strong's numbers
                            if attributedVerse.strongNumbersAvailable {
                                result.append(attributedVerse.embedStrongs(to: currentTestament, using: fontSize))
                            } else {
                                result.append(attributedVerse)
                            }
                        }
                    }
                    return result
                } else {
                    if vrss[0].attributedCompound.strongNumbersAvailable {
                        return vrss.map {$0.attributedCompound.embedStrongs(to: currentTestament, using: fontSize)}
                    }
                    return vrss.map {$0.attributedCompound(size: fontSize)}
                }
            }
        }
        return super.getAttributedString(from: index, loadingTooltip: loadingTooltip)
    }
    
    func getVerses() -> [[NSAttributedString]] {
        var allOfThem: [[NSAttributedString]] = []
        for i in 0..<modules.count {
            allOfThem.append(getAttributedString(from: i, loadingTooltip: false))
        }
        return allOfThem
    }
    
    func incrementFont() {
        fontSize += 1.0
        super.broadcastChanges()
        plistManager.setFont(size: fontSize)
    }
    func decrementFont() {
        fontSize -= 1.0
        super.broadcastChanges()
        plistManager.setFont(size: fontSize)
    }
    
    func getBooks() -> [Book]? {
        return (mainModule?.books?.array as? [Book])?.sorted(by: { (f, s) -> Bool in
            f.number < s.number
        })
    }
    
    func getModulesKey() -> [String] {
        var strings = [String]()
        for module in modules {
            strings.append(module.key!)
        }
        return strings
    }
    
}
