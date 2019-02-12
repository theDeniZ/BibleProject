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
    var currentIndex: SpiritIndex
    var fontSize: CGFloat
    var plistManager: PlistManager { return AppDelegate.plistManager }
    var index: Int = 0
    var delegate: ModelUpdateDelegate?
    
    
    private var timings: Timer?
    private var pages: [Page]? = nil
    
    var shortPath: String {
        let number = Int(currentChapter()?.number ?? Int32(currentIndex.chapter + 1))
        return currentIndex.book + ":\(number)"
    }
    
    override init() {
        currentIndex = AppDelegate.plistManager.getSpirit(from: index) ?? SpiritIndex(book: "", chapter: 0)
        fontSize = AppDelegate.plistManager.getFontSize()
//        currentIndesies = AppDelegate.plistManager.getSpirit()
        super.init()
    }
    
    func readyToDisplay() -> (String, Int)? {
        return (currentIndex.book, currentIndex.chapter)
    }
    
    func set(spiritIndex: SpiritIndex) -> Int {
        let pos = set(book: spiritIndex.book)
        setChapter(number: spiritIndex.chapter)
        broadcastChanges()
        return pos
    }
    
    func set(book: String) -> Int {
        currentIndex.book = book
        plistManager.setSpirit(currentIndex, at: index)
        broadcastChanges()
        return index
    }
    
    func setChapter(number: Int) {
        currentIndex.chapter = number
        plistManager.setSpirit(currentIndex, at: index)
        broadcastChanges()
    }
    
    private func currentBook() -> SpiritBook? {
        return (try? SpiritBook.get(by: currentIndex.book, from: context)) ?? nil
    }
    
    private func currentChapter() -> SpiritChapter? {
        if let book = currentBook(), let chapters = book.chapters?.array as? [SpiritChapter] {
            if chapters.count > currentIndex.chapter {
                if chapters[currentIndex.chapter].index == Int32(currentIndex.chapter) {
                    return chapters[currentIndex.chapter]
                } else {
                    let fil = chapters.filter({$0.index == currentIndex.chapter})
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
    
    func stringValue() -> [NSAttributedString] {
        if let chapter = currentChapter() {
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
                            str.append(NSAttributedString(string: "  \(currentIndex.book) \(numberStr).\(i+1) \n\n", attributes: smallFont))
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
    
    private func broadcastChanges() {
        timings?.invalidate()
        timings = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { (t) in
            self.delegate?.modelChanged()
            t.invalidate()
        }
    }
    
    func doSearch(_ text: String) {
        if text.matches(String.regexForSpiritIndex) {
            let match = text.capturedGroups(withRegex: String.regexForSpiritIndex)!
            if match.count > 0, SpiritBook.exists(with: match[0], in: context) {
                currentIndex.book = match[0]
                plistManager.setSpirit(currentIndex, at: index)
                broadcastChanges()
                if match.count > 1 {
                    if match[1] == ":", match.count > 2 {
                        currentIndex.chapter = Int(match[2])!
                        plistManager.setSpirit(currentIndex, at: index)
                        broadcastChanges()
                        return
                    } else {
//                        pages = []
//                        if let page = Page.get(with: Int(match[1]), from: SpiritBook.ge, searching: <#T##NSManagedObjectContext#>)
                    }
                }
            }
        }
    }
    
    func clearSearch() {
        pages = nil
        broadcastChanges()
    }
}

//
//extension SpiritManager {
//    func getAvailableBooks() -> [String]? {
//        if let books = try? SpiritBook.getAll(from: context), books.count > 0 {
//            var keys = [String]()
//            for book in books {
//                if book.code != nil {
//                    keys.append(book.code!)
//                }
//            }
//            return keys
//        }
//        return nil
//    }
//
//    func getAvailableChapters() -> [String]? {
//        if let book = currentBook() {
//            var names = [String]()
//            if let chapters = book.chapters?.array as? [SpiritChapter] {
//                for chapter in chapters {
//                    if let name = chapter.title {
//                        names.append(name)
//                    }
//                }
//            }
//            return names
//        }
//        return nil
//    }
//
//}
