//
//  VerseTextManager.swift
//  SplitB
//
//  Created by Denis Dobanda on 22.11.18.
//  Copyright © 2018 Denis Dobanda. All rights reserved.
//

import UIKit

class VerseTextManager: TextManager {

    var verses: ([NSAttributedString], [NSAttributedString]?)?
    var versesRanges: ([Range <Int>], [Range<Int>]?)?
    
    init(verses:([NSAttributedString], [NSAttributedString]?)) {
        self.verses = verses
        super.init()
    }
    
    override func placeText(into textStorage: inout NSTextStorage) -> ([Range<Int>], [Int]) {
        var r1: [Range <Int>] = []
        var r2: [Range <Int>] = []


        var currentStartPoint = 0
        if let verses = verses {
            for i in 0..<verses.0.count {
                
                let endpoint = verses.0[i].string.count + currentStartPoint
                r1.append(currentStartPoint..<endpoint)
//                textToDisplayInFirst.append(verses.0[i])
                currentStartPoint = endpoint// + 1
                if verses.1 != nil, i < verses.1!.count, let secondVerse = verses.1?[i] {
                    let endpoint = secondVerse.string.count + currentStartPoint
                    r2.append(currentStartPoint..<endpoint)
//                    textToDisplayInSecond.append(secondVerse)
                    currentStartPoint = endpoint// + 1
                }
                currentStartPoint += 1
            }
            if let secondVerses = verses.1,
                secondVerses.count > verses.0.count {
                for i in verses.0.count..<secondVerses.count {
                    let endpoint = 0 + String(i).count + secondVerses[i].string.count + currentStartPoint
                    r2.append(currentStartPoint..<endpoint)
//                    textToDisplayInSecond.append(secondVerses[i])
                    currentStartPoint = endpoint + 1
                    
                }
            }
            textToDisplayInFirst = verses.0
            if let v2 = verses.1 {
                textToDisplayInSecond = v2
            }
        }

        versesRanges = r2.count > 0 ? (r1, r2) : (r1, nil)
        
        return super.placeText(into: &textStorage)
    }

}
