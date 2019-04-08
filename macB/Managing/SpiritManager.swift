//
//  SpiritManager.swift
//  macB
//
//  Created by Denis Dobanda on 21.01.19.
//  Copyright © 2019 Denis Dobanda. All rights reserved.
//

import Cocoa
import CoreData

class SpiritManager: CoreSpiritManager {
    
    var fontSize: CGFloat
    
    override init() {
        fontSize = AppDelegate.plistManager.getFontSize()
        super.init()
    }
    
    override func stringValue() -> [NSAttributedString] {
        if let chapter = currentChapter() {
            var result = [NSAttributedString]()
            let titleParagraphStyle = NSMutableParagraphStyle()
            titleParagraphStyle.alignment = .center
            var normalFont: NSFont = NSFont.systemFont(ofSize: fontSize)
            var boldFont: NSFont = NSFont.boldSystemFont(ofSize: fontSize)
            var smallFontValue: NSFont = NSFont.systemFont(ofSize: fontSize * 0.6)
            if let namedFont = plistManager.getFont() {
                normalFont = NSFont(name: namedFont, size: fontSize)!
                boldFont = NSFont(name: namedFont, size: fontSize)!
                smallFontValue = NSFont(name: namedFont, size: fontSize * 0.6)!
            }
            
            let font: [NSAttributedString.Key:Any] = [
                .font : normalFont
            ]
            let note: [NSAttributedString.Key:Any] = [
                .font : boldFont,
                .paragraphStyle: titleParagraphStyle
            ]
            let smallFont: [NSAttributedString.Key:Any] = [
                .font : smallFontValue,
                .foregroundColor: NSColor.blue.cgColor
            ]
            
            if let intro = chapter.intro {
                result.append(NSAttributedString(string: intro + "\n\n", attributes: note))
            }
            if let pages = chapter.pages?.array as? [Page] {
                
                for page in pages {
                    var numberStr = ""
                    if page.roman {
                        numberStr = Int(page.number).romanNumeral
                    } else {
                        numberStr = "\(Int(page.number))"
                    }
                    if let paragraphs = page.paragraphs?.array as? [SpiritParagraph] {
                        for i in 0..<paragraphs.count {
                            if let text = paragraphs[i].text {
                                let str = NSMutableAttributedString(string: String(text), attributes: font)
                                str.append(NSAttributedString(string: "  \(currentIndex.book) \(numberStr).\(i+1) \n\n", attributes: smallFont))
                                result.append(str)
                            }
                        }
                    }
                    result.append(NSAttributedString(string: "\n"))
                }
            }
            return result
        }
        return super.stringValue()
    }
    
    override func doSearch(_ text: String) {
        if let matched = text.capturedGroups(withRegex: "(\\w[^\\d])(\\d+)(?:\\.\\d+)?") {
            _ = find(match: matched)
        } else {
            super.doSearch(text)
        }
    }
    
    private func find(match: [String]) -> Int? {
        guard let number = Int(match[1]) else {return nil}
        do {
            let page = try Page.find(number: number, code: match[0], in: context)
            if let ch = page?.chapter, let code = ch.book?.code {
                currentIndex.chapter = Int(ch.index)
                currentIndex.book = code
                plistManager.setSpirit(currentIndex, at: index)
//                _ = presentableValue()
//                if let cache = cached {
//                    for i in 0..<cache.count {
//                        if let n = cache[i].page?.number, n == number {
//                            super.update()
//                            return i + 1
//                        }
//                    }
//                }
                super.update()
                return 0
            }
        } catch {
            print(error)
        }
        return nil
    }
    
}
