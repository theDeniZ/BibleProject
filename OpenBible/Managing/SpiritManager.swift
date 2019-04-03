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
    
    override init() {
        fontSize = AppDelegate.plistManager.getFontSize()
        super.init()
    }
    
    private func getPages() -> [Page]? {
        return currentChapter()?.pages?.array as? [Page]
    }
    
    func presentableValue() -> [Presentable] {
        if let pages = getPages() {
            var result = [Presentable]()
            let titleParagraphStyle = NSMutableParagraphStyle()
            titleParagraphStyle.alignment = .center
            let normalFont: UIFont = UIFont.systemFont(ofSize: fontSize)
            let boldFont: UIFont = UIFont.boldSystemFont(ofSize: fontSize)
            let smallFontValue: UIFont = UIFont.systemFont(ofSize: fontSize * 0.6)
//            if let namedFont = plistManager.getFont() {
//                normalFont = NSFont(name: namedFont, size: fontSize)!
//                boldFont = NSFont(name: namedFont, size: fontSize)!
//                smallFontValue = NSFont(name: namedFont, size: fontSize * 0.6)!
//            }
            
            let font: [NSAttributedString.Key:Any] = [
                .font : normalFont
            ]
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
                        if let text = paragraphs[i].text {
                            let str = NSMutableAttributedString(string: String(text), attributes: font)
                            str.append(NSAttributedString(string: "  \(currentIndex.book) \(numberStr).\(i+1) \n\n", attributes: smallFont))
                            result.append(Presentable(str, index: ordinalIndex))
                        }
                    }
                    ordinalIndex += 1
                }
            }
            return result
        }
        return []
    }
    
    func getBooks() -> [SpiritBook]? {
        return try? SpiritBook.getAll(from: context)
    }
    
    func setBook(withIndex: Int) {
        guard let book = (try? SpiritBook.get(by: withIndex, from: context)) ?? nil else {return}
        currentIndex.book = book.code!
        plistManager.setSpirit(currentIndex, at: index)
        update()
    }
    
    override var description: String {
        return currentIndex.book + ":\(currentIndex.chapter + 1)"
    }
    
    
}


extension SpiritManager: ModelVerseDelegate {
    func isThereANote(at: (module: Int, verse: Int)) -> String? {
        return nil
    }
    
    func setNote(at: (module: Int, verse: Int), _ note: String?) {
        
    }
    
    func isThereAColor(at: (module: Int, verse: Int)) -> Data? {
        return nil
    }
    
    func setColor(at: (module: Int, verse: Int), _ color: Data?) {
        
    }
}
