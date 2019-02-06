//
//  CustomDebugLayout.swift
//  TextViewCustom
//
//  Created by Denis Dobanda on 24.10.18.
//  Copyright © 2018 Denis Dobanda. All rights reserved.
//

import UIKit

class CustomDebugLayoutManager: NSLayoutManager {
    
    var selectedRange: NSRange?
    var selectionColor: UIColor?
    var width: CGFloat!
    
    override func drawBackground(forGlyphRange glyphsToShow: NSRange, at origin: CGPoint) {
        self.enumerateLineFragments(forGlyphRange:NSMakeRange(0, self.numberOfGlyphs)) {
            (rect, usedRect, textContainer, glyphRange, Bool) in
            
            let lineBoundingRect = self.boundingRect(forGlyphRange: glyphRange, in: textContainer)
            let adjustedLineRect = lineBoundingRect.offsetBy(dx: origin.x, dy: origin.y)
            let fillColorPath: UIBezierPath = UIBezierPath(roundedRect: adjustedLineRect, cornerRadius: 0)
            UIColor.white.setFill()
            fillColorPath.fill()
            if let selection = self.selectedRange, let inter = selection.intersection(glyphRange) {
                let lineBoundingRect = self.boundingRect(forGlyphRange: inter, in: textContainer)
                let adjustedLineRect = lineBoundingRect.offsetBy(dx: origin.x, dy: origin.y)
                let fillColorPath: UIBezierPath = UIBezierPath(roundedRect: adjustedLineRect, cornerRadius: 0)
                (self.selectionColor ?? UIColor.blue).setFill()
                fillColorPath.fill()
            }
        }
    }
    
    override func fillBackgroundRectArray(_ rectArray: UnsafePointer<CGRect> , count rectCount: Int, forCharacterRange charRange: NSRange, color: UIColor) {
        for i in 0..<rectCount {
            let path = UIBezierPath(roundedRect: rectArray[i], cornerRadius: 0)
            color.set()
            path.fill()
            path.stroke()
        }
    }
    
    override func drawGlyphs(forGlyphRange glyphsToShow: NSRange, at origin: CGPoint) {
        super.drawGlyphs(forGlyphRange: glyphsToShow, at: origin)
        if let twoCol = textContainers[0] as? TwoColumnContainer {
            
        }
    }
    
    override func glyphIndex(for point: CGPoint, in container: NSTextContainer) -> Int {
        if let twoConlumn = container as? TwoColumnContainer, twoConlumn.manager!.dividers.count == 0  || point.y < width / 2 {
            let index = super.glyphIndex(for: point, in: container)
            print(index)
            return index
        } else {
            let index = super.glyphIndex(for: point, in: container)
            print(index)
            return index
        }
    }
}
