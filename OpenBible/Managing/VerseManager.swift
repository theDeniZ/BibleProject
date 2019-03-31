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
    var isStrongsOn: Bool { return plistManager.isStrongsOn }
    
    override init(_ context: NSManagedObjectContext) {
        fontSize = AppDelegate.plistManager.getFontSize()
        super.init(context)
    }
    
    func getAttributedString(from index: Int, loadingTooltip: Bool) -> [Presentable] {
        let strongs = isStrongsOn
        if let chapter = chapter(index) {
            if let vrss = chapter.verses?.array as? [Verse] {
                if let vs = verses {
                    var result = [Presentable]()
                    for range in vs {
                        let versesFiltered = vrss.filter {range.contains(Int($0.number))}
                        for verse in versesFiltered {
                            let attributedVerse = verse.attributedCompound(size: fontSize)
                            //check for strong's numbers
                            if attributedVerse.strongNumbersAvailable {
                                let text = attributedVerse.embedStrongs(to: currentTestament, using: fontSize, linking: strongs)
                                result.append(Presentable(text, index: Int(verse.number)))
                            } else {
                                result.append(Presentable(attributedVerse, index: Int(verse.number)))
                            }
                        }
                    }
                    return result
                } else {
                    if vrss[0].attributedCompound.strongNumbersAvailable {
                        return vrss.map {Presentable($0.attributedCompound.embedStrongs(to: currentTestament, using: fontSize, linking: strongs), index: Int($0.number))}
                    }
                    return vrss.map {Presentable($0.attributedCompound(size: fontSize), index: Int($0.number))}
                }
            }
        }
        return []//super.getAttributedString(from: index, loadingTooltip: loadingTooltip)
    }
    
    func getVerses() -> [[Presentable]] {
        var allOfThem: [[Presentable]] = []
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

extension VerseManager: ModelVerseDelegate {
    
    func isThereANote(at index: (module: Int, verse: Int)) -> String? {
        return (chapter(index.module)?.verses!.array as! [Verse])[index.verse - 1].note
    }
    
    func isThereAColor(at index: (module: Int, verse: Int)) -> Data? {
        return (chapter(index.module)?.verses!.array as! [Verse])[index.verse - 1].color
    }
    
    func setNote(at index: (module: Int, verse: Int), _ note: String?) {
        (chapter(index.module)?.verses!.array as! [Verse])[index.verse - 1].note = note
        try? context.save()
        broadcastChanges()
    }
    
    func setColor(at index: (module: Int, verse: Int), _ color: Data?) {
        (chapter(index.module)?.verses!.array as! [Verse])[index.verse - 1].color = color
        try? context.save()
        broadcastChanges()
    }
}
