//
//  CoreManager.swift
//  macB
//
//  Created by Denis Dobanda on 23.12.18.
//  Copyright © 2018 Denis Dobanda. All rights reserved.
//

import Foundation
import CoreData

internal class VerseManager: CoreManager {
    
    var fontSize: CGFloat
    var strongsNumbersIsOn: Bool = true {didSet {plistManager.setStrong(on: strongsNumbersIsOn);broadcastChanges()}}
    
    var layoutManager = CVLayoutManager()
    
    var countMax: Int {
        var m = 0
        for i in 0..<modules.count {
            if let c = chapter(i)?.verses?.array.count {
                m = max(m, c)
            }
        }
        return m
    }
    
    override init(_ context: NSManagedObjectContext) {
        fontSize = AppDelegate.plistManager.getFontSize()
        strongsNumbersIsOn = AppDelegate.plistManager.isStrongsIsOn
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
                                result.append(attributedVerse.embedStrongs(to: currentTestament, using: fontSize, linking: strongsNumbersIsOn, withTooltip: loadingTooltip))
                            } else {
                                result.append(attributedVerse)
                            }
                        }
                    }
                    return result
                } else {
                    if vrss[0].attributedCompound.strongNumbersAvailable {
                        return vrss.map {$0.attributedCompound.embedStrongs(to: currentTestament, using: fontSize, linking: strongsNumbersIsOn, withTooltip: loadingTooltip)}
                    }
                    return vrss.map {$0.attributedCompound(size: fontSize)}
                }
            }
        }
        return []
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
        broadcastChanges()
        plistManager.setFont(size: fontSize)
    }
    func decrementFont() {
        fontSize -= 1.0
        broadcastChanges()
        plistManager.setFont(size: fontSize)
    }
    
    override func broadcastChanges() {
        layoutManager.arrayOfVerses = getVerses()
        super.broadcastChanges()
    }
    
    override func update(_ full: Bool = false) {
        layoutManager.arrayOfVerses = getVerses()
        super.update(full)
    }
}


extension VerseManager: ModelVerseDelegate {

    func isThereANote(at index: (module: Int, verse: Int)) -> String? {
        return (chapter(index.module)?.verses!.array as! [Verse])[index.verse].note
    }
    
    func setNote(at index: (module: Int, verse: Int), _ note: String?) {
        (chapter(index.module)?.verses!.array as! [Verse])[index.verse].note = note
        try? context.save()
    }
}
