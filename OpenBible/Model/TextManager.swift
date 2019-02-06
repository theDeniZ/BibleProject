//
//  Model.swift
//  TextViewCustom
//
//  Created by Denis Dobanda on 24.10.18.
//  Copyright © 2018 Denis Dobanda. All rights reserved.
//

import UIKit

class TextManager: NSObject {
    
    var textToDisplayInFirst: [NSAttributedString]
    var textToDisplayInSecond: [NSAttributedString]
    
    var textStorage: NSTextStorage!
    var layoutManager: CustomDebugLayoutManager!
    var textContainer: TwoColumnContainer!
    var fontSize: CGFloat = 30
    
    override init() {
        textToDisplayInFirst = []
        textToDisplayInSecond = []
    }
    
    init(first: [NSAttributedString], second: [NSAttributedString]) {
        textToDisplayInFirst = first
        textToDisplayInSecond = second
    }
    
    func placeText(into textStorage: inout NSTextStorage) -> ([Range<Int>], [Int]) {
        var ranges: [Range <Int>] = []
        var dividers: [Int] = []
        
        var m = min(textToDisplayInFirst.count, textToDisplayInSecond.count)
        
        if m == 0, textToDisplayInSecond.count != 0 {
            swap(&textToDisplayInFirst, &textToDisplayInSecond)
        }
        
//        let font: [NSAttributedString.Key:Any] =
//            [.font:UIFont.systemFont(ofSize:fontSize),
//             .baselineOffset : 0]
//        let small: [NSAttributedString.Key: Any] =
//            [.font : UIFont.italicSystemFont(ofSize: fontSize * 0.6),
//             .baselineOffset : fontSize * 0.3,
//             .foregroundColor : UIColor.gray.withAlphaComponent(0.7)]
//
        let nl = NSAttributedString(string: "\n")//, attributes: [.font:UIFont.systemFont(ofSize:fontSize / 5)])
        var startRange = 0
//        var lenghtOfStartingLine = 0
        for i in 0..<m {
            let t1 = textToDisplayInFirst[i]
                /*NSMutableAttributedString(string: " ", attributes: font)
            t1.append(NSAttributedString(string: "\(i + 1) ", attributes: small))
            lenghtOfStartingLine = t1.length
            t1.append(textToDisplayInFirst[i])
            t1.addAttributes(font, range: NSRange(lenghtOfStartingLine..<t1.length))*/
            textStorage.append(t1)
            
            let t2 = textToDisplayInSecond[i]/*NSMutableAttributedString(string: " ", attributes: font)
            t2.append(NSAttributedString(string: "\(i + 1) ", attributes: small))
            t2.append(textToDisplayInSecond[i])
            t2.addAttributes(font, range: NSRange(lenghtOfStartingLine..<t2.length))*/
            textStorage.append(t2)
            
            startRange += t1.length// + 1
            ranges.append(startRange..<startRange + t2.length)
            startRange += t2.length// + 1
            if ( i != m ) {
                textStorage.append(nl)
                dividers.append(startRange)
                startRange += 1
            }
        }
        
        if m < textToDisplayInFirst.count {
            let c = textToDisplayInFirst.count
            if m > 0 {
                textStorage.append(nl)
//                textStorage.append(nl)
//                startRange += 1
                dividers.append(startRange)
                startRange += 2
            }
            while m < c {
                let t1 = textToDisplayInFirst[m]/*NSMutableAttributedString(string: " ", attributes: font)
                t1.append(NSAttributedString(string: "\(m + 1) ", attributes: small))
                lenghtOfStartingLine = t1.length
                t1.append(textToDisplayInFirst[m])
                t1.addAttributes(font, range: NSRange(lenghtOfStartingLine..<t1.length))*/
                textStorage.append(t1)
                startRange += t1.length
                if (m != c ) {
                    textStorage.append(nl)
                    //                    textStorage.append(nl)
                    
                    dividers.append(startRange)
                    startRange += 1
                }
                m += 1
            }
        } else if m < textToDisplayInSecond.count {
            let c = textToDisplayInSecond.count
            if m > 0 {
                textStorage.append(nl)
//                textStorage.append(nl)
//                startRange += 1
                dividers.append(startRange)
                startRange += 2
            }
            while m < c {
                let t1 = textToDisplayInSecond[m]/*NSMutableAttributedString(string: " ", attributes: font)
                t1.append(NSAttributedString(string: "\(m + 1) ", attributes: small))
                lenghtOfStartingLine = t1.length
                t1.append(textToDisplayInSecond[m])
                t1.addAttributes(font, range: NSRange(lenghtOfStartingLine..<t1.length))*/
                textStorage.append(t1)
                ranges.append(startRange..<startRange + t1.length)
                startRange += t1.length
                if (m < c ) {
                    textStorage.append(nl)
                    //                    textStorage.append(nl)
                    
                    dividers.append(startRange)
                    startRange += 2
                }
                m += 1
            }
        }
        return (ranges, dividers)
    }
    
    func getContainer(in bounds: CGSize) -> NSTextContainer {
        
        textStorage = NSTextStorage()
        let (ranges, dividers) = placeText(into: &textStorage)
        
        layoutManager = CustomDebugLayoutManager()
        layoutManager.width = bounds.width
        layoutManager.allowsNonContiguousLayout = false
        let containerSize = CGSize(width: bounds.width, height: .greatestFiniteMagnitude)
        textContainer = TwoColumnContainer(size: containerSize)
        let manager = TwoColumnPositioningManager(containerSize, ranges: ranges, dividers: dividers, height: 0.0)
//        container.rangesForSecond = textToDisplayInSecond.count > 0 ? ranges : nil
//        container.dividers = dividers
        textContainer.manager = manager
        textContainer.widthTracksTextView = true
        textContainer.heightTracksTextView = true
        layoutManager.addTextContainer(textContainer)
        
        textStorage.addLayoutManager(layoutManager)
        
        return textContainer
    }
    
}
