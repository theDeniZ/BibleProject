//
//  VerseTextView.swift
//  SplitB
//
//  Created by Denis Dobanda on 25.11.18.
//  Copyright © 2018 Denis Dobanda. All rights reserved.
//

import UIKit

class VerseTextView: CustomTextView {

    var executeRightAfterDrawingOnce: (() -> ())?
    
    var verseTextManager: VerseTextManager!
    override var textManager: TextManager! {
        get { return verseTextManager }
        set { print ( "Error: Set of textManager in VerseTextView") }
    }
    
    internal var boundingRectsForVerses: ([CGRect], [CGRect]?)?
    
    var selectedFirstVerse: (Int, Bool)?
    var selectedSecondVerse: (Int, Bool)?
    private var versesRanges: ([Range <Int>], [Range<Int>]?)? {
        return verseTextManager.versesRanges
    }
    
    func getRectOf(_ number: Int) -> CGRect? {
        if boundingRectsForVerses != nil,
            boundingRectsForVerses!.0.count >= number {
            if boundingRectsForVerses!.1 != nil {
                return CGRect(bounding: boundingRectsForVerses!.0[number - 1],
                              with: boundingRectsForVerses!.1![number - 1])
            }
            return boundingRectsForVerses!.0[number - 1]
        }
        return nil
    }
    
    func selectVerse(at point: CGPoint) -> CGRect? {
        if let rects = boundingRectsForVerses {
            for i in 0..<rects.0.count {
                if rects.0[i].contains(point) {
                    selectVerse(number: i)
                    return rects.0[i]
                }
            }
            if let second = rects.1 {
                for i in 0..<second.count {
                    if second[i].contains(point) {
                        selectVerse(number: i, first: false)
                        return second[i]
                    }
                }
            }
        }
        return nil
    }
    
    func highlight(_ verse: Int, throught: Int) {
        guard verse <= throught else {return}
        guard let r1 = getRectOf(verse), let r2 = getRectOf(throught) else {return}
        var r = CGRect(bounding: r1, with: r2)
        r.size.width = bounds.width
        let newView = UIView(frame: r)
        newView.backgroundColor = UIColor.yellow.withAlphaComponent(0.4)
        addSubview(newView)
        UIView.animate(withDuration: 1.0, delay: 1, animations: {
            newView.layer.opacity = 0
        }) { (_) in
            newView.removeFromSuperview()
        }
    }
    
    func highlight(_ verse: Int) {
        highlight(verse, throught: verse)
    }
    
    private func selectVerse(number: Int, first: Bool = true) {
        var rangeCh: Range <Int>
        if selectedFirstVerse == nil {
            rangeCh = first ? versesRanges!.0[number] : versesRanges!.1![number]
            selectedFirstVerse = (number, first)
        } else {
            if let second = selectedSecondVerse {
                if selectedFirstVerse!.0 < number && second.0 > number {
                    clearSelection()
                    return
                } else if selectedFirstVerse!.0 > number && second.0 < number {
                    clearSelection()
                    return
                } else if selectedFirstVerse!.0 == number && selectedFirstVerse!.1 == first {
                    clearSelection()
                    return
                } else if second.0 == number && second.1 == first {
                    clearSelection()
                    return
                }
            } else if number == selectedFirstVerse!.0 && first == selectedFirstVerse!.1 {
                clearSelection()
                return
            }
            var lower: Int
            var upper: Int
            if selectedFirstVerse!.0 < number || ( selectedFirstVerse!.0 == number && selectedFirstVerse!.1 == true) {
                lower = selectedFirstVerse!.1 ? versesRanges!.0[selectedFirstVerse!.0].lowerBound : versesRanges!.1![selectedFirstVerse!.0].lowerBound
                upper = first ? versesRanges!.0[number].upperBound : versesRanges!.1![number].upperBound
            } else {
                upper = selectedFirstVerse!.1 ? versesRanges!.0[selectedFirstVerse!.0].upperBound : versesRanges!.1![selectedFirstVerse!.0].upperBound
                lower = first ? versesRanges!.0[number].lowerBound : versesRanges!.1![number].lowerBound
            }
            rangeCh = lower..<upper
            selectedSecondVerse = (number, first)
        }
        var ixStart = rangeCh.lowerBound//layoutManager.glyphIndexForCharacter(at: rangeCh.lowerBound)
        var ixEnd = rangeCh.upperBound//layoutManager.glyphIndexForCharacter(at: rangeCh.upperBound)
        var range: NSRange
        if ixStart > ixEnd {
            swap(&ixStart, &ixEnd)
        }
        
        let s = layoutManager.textStorage!.string
        var sub = String(s[..<s.index(s.startIndex, offsetBy:ixStart)])
        var count = sub.indicesOf(string: "\r\n").count
//        if boundingRectsForVerses?.1 != nil {
//            count /= 2
//        }
        ixStart += count
//        var charRange = layoutManager.characterRange(forGlyphRange: NSRange(ixStart - count..<ixEnd - count), actualGlyphRange: nil)
//        while(charRange.lowerBound > 1 && !separators.contains(s[s.index(s.startIndex, offsetBy: charRange.lowerBound - 1)])) {
//            charRange.location -= 1
//            charRange.length += 1
//            ixStart -= 1
//        }
        
        sub = s[rangeCh.lowerBound - count..<rangeCh.upperBound - count]
        if boundingRectsForVerses?.1 != nil {
            count += (sub.indicesOf(string: "\r\n").count - 1)
        } else {
            count += sub.indicesOf(string: "\r\n").count - 1
        }
        
//        charRange.length -= count
//        while(charRange.upperBound < s.count - 1 && !separators.contains(s[s.index(s.startIndex, offsetBy: charRange.upperBound + 1)])) {
//            charRange.length += 1
//            ixEnd += 1
//        }
        ixEnd += count
        range = NSRange(ixStart...ixEnd)
        previousRange = range
        layoutManager.selectedRange = range
        setNeedsDisplay()
    }
    
    override func clearSelection() {
        super.clearSelection()
        selectedFirstVerse = nil
        selectedSecondVerse = nil
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        if let versesRanges = verseTextManager.versesRanges {
            let wid = bounds.width / 2
            let first = versesRanges.0
            var rects1: [CGRect] = []
            var rects2: [CGRect] = []
            for i in 0..<first.count {
                var range = first[i]
                /* next line is becouse of invisible glyphs */
                range = range.lowerBound + i ..< range.upperBound + i
                let glyphRange = layoutManager.glyphRange(forCharacterRange: range.nsRange, actualCharacterRange: nil
                )
                var rect = layoutManager.boundingRect(forGlyphRange: glyphRange, in: textContainer)
                rect.size.width = wid
                rects1.append(rect)
                
                if versesRanges.1 != nil, i < versesRanges.1!.count, let second = versesRanges.1?[i] {
                    var range = second
                    /* next line is becouse of invisible glyphs */
                    range = range.lowerBound + i ..< range.upperBound + i
                    let glyphRange2 = layoutManager.glyphRange(forCharacterRange: range.nsRange, actualCharacterRange: nil
                    )
                    var rect2 = layoutManager.boundingRect(forGlyphRange: glyphRange2, in: textContainer)
                    rect2.size.width = wid
                    rect2.origin.x = rect.origin.x + wid
                    rects2.append(rect2)
                }
            }
            
            if let second = versesRanges.1,
                second.count > first.count {
                for i in first.count..<second.count {
                    var range = second[i]
                    /* next line is becouse of invisible glyphs */
                    range = range.lowerBound + i ..< range.upperBound + i
                    let glyphRange2 = layoutManager.glyphRange(forCharacterRange: range.nsRange, actualCharacterRange: nil
                    )
                    var rect2 = layoutManager.boundingRect(forGlyphRange: glyphRange2, in: textContainer)
                    rect2.size.width = wid
                    rect2.origin.x = rects2[i-1].origin.x
                    rects2.append(rect2)
                }
            }
            
            boundingRectsForVerses = rects2.count > 0 ? (rects1, rects2) : (rects1, nil)
        }
//        print(boundingRectsForVerses)
        executeRightAfterDrawingOnce?()
        executeRightAfterDrawingOnce = nil
    }

}
