//
//  CustomTextView.swift
//  SplitB
//
//  Created by Denis Dobanda on 26.10.18.
//  Copyright © 2018 Denis Dobanda. All rights reserved.
//

import UIKit

class CustomTextView: UIView {
    
    var textManager: TextManager!
    var delegate: TextViewDelegate?
    
    internal var layoutManager: CustomDebugLayoutManager { return textManager.layoutManager }
    internal var textContainer: NSTextContainer! { return textManager!.textContainer }
    internal var separators: [Character] = [" ", ".", ",", "?", ":", ";", "\n", "!", "(", ")"]
    internal var previousRange: NSRange?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        _ = textManager.getContainer(in: bounds.size)
        layoutManager.selectionColor = UIColor.blue.withAlphaComponent(0.4)
        setNeedsDisplay()
    }
    
    func selectText(from start: CGPoint, to end: CGPoint) {
        var f: CGFloat = 0
        var ixStart = layoutManager.glyphIndex(for: start, in: textContainer, fractionOfDistanceThroughGlyph: &f)
        var ixEnd = layoutManager.glyphIndex(for: end, in: textContainer, fractionOfDistanceThroughGlyph: &f)
        var range: NSRange
        if ixStart > ixEnd {
            swap(&ixStart, &ixEnd)
        }
        let s = layoutManager.textStorage!.string
        var sub = String(s[..<s.index(s.startIndex, offsetBy:ixStart)])
        var count = sub.indicesOf(string: "\r\n").count
        var charRange = layoutManager.characterRange(forGlyphRange: NSRange(ixStart - count..<ixEnd - count), actualGlyphRange: nil)
        while(charRange.lowerBound > 1 && !separators.contains(s[s.index(s.startIndex, offsetBy: charRange.lowerBound - 1)])) {
            charRange.location -= 1
            charRange.length += 1
            ixStart -= 1
        }
        sub = String(s[s.index(s.startIndex, offsetBy: charRange.lowerBound)..<s.index(s.startIndex, offsetBy: charRange.upperBound)])
        count = sub.indicesOf(string: "\r\n").count
        charRange.length -= count
        while(charRange.upperBound < s.count - 1 && !separators.contains(s[s.index(s.startIndex, offsetBy: charRange.upperBound + 1)])) {
            charRange.length += 1
            ixEnd += 1
        }
        range = NSRange(ixStart...ixEnd)
        previousRange = range
        layoutManager.selectedRange = range
        setNeedsDisplay()
    }
    
    func getSelection() -> String? {
//        var s: String?
        if let glyphRange = previousRange {
            
            if let str = layoutManager.textStorage?.string {
                let sub = String(str[..<str.index(str.startIndex, offsetBy:glyphRange.lowerBound)])
                var count = sub.indicesOf(string: "\r\n").count
                var charRange = glyphRange
                charRange.location -= count
                var s = str[charRange.lowerBound..<charRange.upperBound]
                count = s.indicesOf(string: "\r\n").count
                if count > 0 {
                    s = String(s[s.index(s.startIndex, offsetBy: count - 1)..<s.index(s.endIndex, offsetBy: -count + 1)])
                }
                return s
//                let prev = layoutManager.characterRange(forGlyphRange: charRange, actualGlyphRange: nil)
//                s = String(str[str.index(str.startIndex, offsetBy: prev.lowerBound)..<str.index(str.startIndex, offsetBy: prev.upperBound)])
//
//                s = String(s![..<s!.index(s!.endIndex, offsetBy: -count)])
            }
        }
        return nil
    }
    
    func getSelectionLink(at point: CGPoint) -> String? {
        var f: CGFloat = 0
        let ixStart = layoutManager.glyphIndex(for: point, in: textContainer, fractionOfDistanceThroughGlyph: &f)
        
        let s = layoutManager.textStorage!.string
        let sub = String(s[..<s.index(s.startIndex, offsetBy:ixStart)])
        let count = sub.indicesOf(string: "\r\n").count
        let charRange = layoutManager.characterRange(forGlyphRange: NSRange(ixStart - count..<ixStart - count + 1), actualGlyphRange: nil)
        let link = layoutManager.textStorage!.attributedSubstring(from: charRange).attribute(.link, at: 0, effectiveRange: nil) as? String
        return link
        /*
        while(charRange.lowerBound > 1 && !separators.contains(s[s.index(s.startIndex, offsetBy: charRange.lowerBound - 1)])) {
            charRange.location -= 1
            charRange.length += 1
            ixStart -= 1
        }
        sub = String(s[s.index(s.startIndex, offsetBy: charRange.lowerBound)..<s.index(s.startIndex, offsetBy: charRange.upperBound)])
        count = sub.indicesOf(string: "\r\n").count
        charRange.length -= count
        while(charRange.upperBound < s.count - 1 && !separators.contains(s[s.index(s.startIndex, offsetBy: charRange.upperBound + 1)])) {
            charRange.length += 1
            ixEnd += 1
        }
        range = NSRange(ixStart...ixEnd)
        previousRange = range
        layoutManager.selectedRange = range
 */
    }
    
    func clearSelection() {
        layoutManager.selectedRange = nil
        previousRange = nil
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        
        let path = UIBezierPath(roundedRect: bounds, cornerRadius: 0)
        UIColor.white.set()
        path.fill()
        
        var rect1 = rect
        let r = layoutManager.glyphRange(for: textContainer)
        _ = withUnsafePointer(to: &rect1) { (p) -> Bool in
            layoutManager.fillBackgroundRectArray(p, count: 1, forCharacterRange: r, color: UIColor.white)
            return true
        }
        layoutManager.drawBackground(forGlyphRange:r, at:CGPoint(x: 0, y: 0))
        layoutManager.drawGlyphs(forGlyphRange:r, at:CGPoint(x: 0, y: 0))
        let usedRect = layoutManager.usedRect(for: textContainer)
        frame = CGRect(origin: frame.origin, size: CGSize(width: frame.width, height: usedRect.height))
        delegate?.textViewDidResize(to: usedRect.size)
        
        
        bounds.size.height = usedRect.height
        center.y = usedRect.height / 2
        
    }
    
}
