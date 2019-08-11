//
//  SpiritManager.swift
//  OpenBible
//
//  Created by Denis Dobanda on 02.04.19.
//  Copyright © 2019 Denis Dobanda. All rights reserved.
//

import UIKit
import CoreData

class SpiritManager: CoreSpiritManager {
    
    var fontSize: CGFloat
    
    override var currentIndex: SpiritIndex {
        get {
            return super.currentIndex
        }
        set {
            super.currentIndex = newValue
            cachedPresentable = nil
            cached = nil
        }
    }
    
    private var cached: [SpiritParagraph]?
    private var cachedPresentable: [Presentable]?
    
    override init() {
        fontSize = PlistManager.shared.getFontSize()
        super.init()
    }
    
    private func getPages() -> [Page]? {
        return currentChapter()?.pages?.array as? [Page]
    }
    
    func presentableValue() -> [Presentable] {
        if cachedPresentable != nil {
            return cachedPresentable!
        }
        if let pages = getPages() {
            var result = [Presentable]()
            let titleParagraphStyle = NSMutableParagraphStyle()
            titleParagraphStyle.alignment = .center
            let font: UIFont = UIFont.systemFont(ofSize: fontSize)
            let boldFont: UIFont = UIFont.boldSystemFont(ofSize: fontSize)
            let smallFontValue: UIFont = UIFont.systemFont(ofSize: fontSize * 0.6)
//            if let namedFont = plistManager.getFont() {
//                normalFont = NSFont(name: namedFont, size: fontSize)!
//                boldFont = NSFont(name: namedFont, size: fontSize)!
//                smallFontValue = NSFont(name: namedFont, size: fontSize * 0.6)!
//            }
            
//            let font: [NSAttributedString.Key:Any] = [
//                .font : normalFont
//            ]
            let note: [NSAttributedString.Key:Any] = [
                .font : boldFont,
                .paragraphStyle: titleParagraphStyle
            ]
            let smallFont: [NSAttributedString.Key:Any] = [
                .font : smallFontValue,
                .foregroundColor: UIColor.blue
            ]
            
            if let intro = currentChapter()?.intro {
                result.append(Presentable(NSAttributedString(string: intro + "\n\n", attributes: note), index: 0))
            }
//            if let pages = chapter.pages?.array as? [Page] {
            var allOfPresentedParagraphs = [SpiritParagraph]()
            var ordinalIndex = 1
            for page in pages {
                var numberStr = ""
                if page.roman {
                    numberStr = Int(page.number).romanNumeral
                } else {
                    numberStr = "\(Int(page.number))"
                }
                if let paragraphs = page.paragraphs?.array as? [SpiritParagraph] {
//                    let paragraphs = text.split(separator: "\n")
                    for i in 0..<paragraphs.count {
                        let str = NSMutableAttributedString(attributedString: paragraphs[i].attributedCompound(font: font))
//                            let str = NSMutableAttributedString(string: String(text), attributes: font)
                            str.append(NSAttributedString(string: "  \(currentIndex.book) \(numberStr).\(i+1) \n\n", attributes: smallFont))
                            result.append(Presentable(str, index: ordinalIndex, hasNote: paragraphs[i].note != nil))
                            ordinalIndex += 1
//                        }
                    }
                    allOfPresentedParagraphs.append(contentsOf: paragraphs)
                }
            }
            cached = allOfPresentedParagraphs
            cachedPresentable = result
            return result
        }
        return []
    }
    
    func getBooks() -> [SpiritBook]? {
        return try? SpiritBook.getAll(from: context)
    }
    
    func setBook(withIndex: Int) {
        guard let book = try? SpiritBook.get(by: withIndex, from: context) else {return}
        currentIndex.book = book.code!
        PlistManager.shared.setSpirit(currentIndex, at: index)
        update()
    }
    
    override var description: String {
        return currentIndex.book + ":\(currentChapter()?.number ?? 0)"
    }
    
    func find(reference: String) -> Int? {
        guard let matched = reference.capturedGroups(withRegex: "(\\w[^\\d])(\\d+)(?:\\.\\d+)?"),
                let number = Int(matched[1]) else {return nil}
        
        do {
            let page = try Page.find(number: number, code: matched[0], in: context)
            if let ch = page?.chapter, let code = ch.book?.code {
                currentIndex.chapter = Int(ch.index)
                currentIndex.book = code
                PlistManager.shared.setSpirit(currentIndex, at: index)
                _ = presentableValue()
                if let cache = cached {
                    for i in 0..<cache.count {
                        if let n = cache[i].page?.number, n == number {
                            super.update()
                            return i + 1
                        }
                    }
                }
                super.update()
                return 0
            }
        } catch {
            print(error)
        }
        return nil
    }
    
}


extension SpiritManager: ModelVerseDelegate {
    func isThereANote(at: (module: Int, verse: Int)) -> String? {
        return nil
    }
    
    func setNote(at index: (module: Int, verse: Int), _ note: String?) {
        guard let cache = cached else {return}
        cache[index.verse - 1].note = note
        try? context.save()
    }
    
    func isThereAColor(at: (module: Int, verse: Int)) -> Data? {
        return nil
    }
    
    func setColor(at index: (module: Int, verse: Int), _ color: Data?) {
        guard let cache = cached else {return}
        cache[index.verse - 1].color = color
        try? context.save()
    }
}
