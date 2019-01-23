//
//  SpiritManager.swift
//  macB
//
//  Created by Denis Dobanda on 21.01.19.
//  Copyright © 2019 Denis Dobanda. All rights reserved.
//

import Cocoa
import CoreData

struct SpiritIndex {
    var book: String
    var chapter: Int
}

class SpiritManager: NSObject {
    
    var context: NSManagedObjectContext = AppDelegate.context
    var currentIndesies: [SpiritIndex]?
    var fontSize: CGFloat
    var plistManager: PlistManager { return AppDelegate.plistManager }
    
    override init() {
        fontSize = AppDelegate.plistManager.getFontSize()
        currentIndesies = AppDelegate.plistManager.getSpirit()
        super.init()
    }
    
    func readyToDisplay(at index: Int) -> (String, Int)? {
        if currentIndesies != nil, currentIndesies!.count > index {
            return (currentIndesies![index].book, currentIndesies![index].chapter)
        }
        return nil
    }
    
    func set(spiritIndex: SpiritIndex, at position: Int) -> Int {
        let pos = set(book: spiritIndex.book, at: position)
        setChapter(number: spiritIndex.chapter, at: pos)
        return pos
    }
    
    func set(book: String, at index: Int) -> Int {
        if currentIndesies == nil {
            currentIndesies = []
        }
        if currentIndesies!.count <= index {
            currentIndesies!.append(SpiritIndex(book: book, chapter: 0))
            plistManager.setSpirit(indicies: currentIndesies)
            return currentIndesies!.count - 1
        } else {
            currentIndesies![index].book = book
            plistManager.setSpirit(indicies: currentIndesies)
            return index
        }
    }
    
    func setChapter(number: Int, at index: Int) {
        guard currentIndesies != nil, currentIndesies!.count > index else {return}
        currentIndesies![index].chapter = number
        plistManager.setSpirit(indicies: currentIndesies)
    }
    
    func getAvailableBooks() -> [String]? {
        if let books = try? SpiritBook.getAll(from: context), books.count > 0 {
            var keys = [String]()
            for book in books {
                if book.code != nil {
                    keys.append(book.code!)
                }
            }
            return keys
        }
        return nil
    }
    
    func getAvailableChapters(index: Int) -> [String]? {
        if let book = currentBook(index: index) {
            var names = [String]()
            if let chapters = book.chapters?.array as? [SpiritChapter] {
                for chapter in chapters {
                    if let name = chapter.title {
                        names.append(name)
                    }
                }
            }
            return names
        }
        return nil
    }
    
    private func currentBook(index: Int) -> SpiritBook? {
        guard currentIndesies != nil, currentIndesies!.count > index, let key = currentIndesies?[index].book else {return nil}
        return (try? SpiritBook.get(by: key, from: context)) ?? nil
    }
    
    private func currentChapter(index: Int) -> SpiritChapter? {
        guard currentIndesies != nil, currentIndesies!.count > index, let number = currentIndesies?[index].chapter else {return nil}
        if let book = currentBook(index: index), let chapters = book.chapters?.array as? [SpiritChapter] {
            if chapters.count > number {
                if chapters[number].index == Int32(number) {
                    return chapters[number]
                } else {
                    let fil = chapters.filter({$0.index == number})
                    if fil.count == 1 {
                        return fil[0]
                    } else {
                        print("Database inconsistency at SpiritManager.currentChapter(\(index))")
                    }
                }
            }
        }
        return nil
    }
    
    subscript(n: Int) -> [NSAttributedString] {
        if let chapter = currentChapter(index: n) {
            var result = [NSAttributedString]()
            let titleParagraphStyle = NSMutableParagraphStyle()
            titleParagraphStyle.alignment = .center
            
            let font: [NSAttributedString.Key:Any] = [
                .font : NSFont.systemFont(ofSize: fontSize)
            ]
            let note: [NSAttributedString.Key:Any] = [
                .font : NSFont.boldSystemFont(ofSize: fontSize),
                .paragraphStyle: titleParagraphStyle
            ]
            let smallFont: [NSAttributedString.Key:Any] = [
                .font : NSFont.systemFont(ofSize: fontSize * 0.6),
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
                    if let text = page.text {
                        let paragraphs = text.split(separator: "\n")
                        for i in 0..<paragraphs.count {
                            let str = NSMutableAttributedString(string: String(paragraphs[i]), attributes: font)
                            str.append(NSAttributedString(string: "  [\(currentIndesies![n].book) \(numberStr).\(i+1)] \n\n", attributes: smallFont))
                            result.append(str)
                        }
                    }
                    result.append(NSAttributedString(string: "\n"))
                }
            }
            return result
        }
        return []
    }
    
}
