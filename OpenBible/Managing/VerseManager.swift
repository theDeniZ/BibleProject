//
//  VerseManager.swift
//  SplitB
//
//  Created by Denis Dobanda on 22.11.18.
//  Copyright © 2018 Denis Dobanda. All rights reserved.
//

import UIKit

class VerseManager: Manager {

    private var versesRanges: [Range<Int>]?
    var fontSize: CGFloat = AppDelegate.plistManager.getFontSize()
    
    private var currentTestament: String {
        return bookNumber <= 39 ? StrongIdentifier.oldTestament : StrongIdentifier.newTestament
    }
    
    private var defaultModule: Module? {
        if let m = try? Module.get(by: "kjv", from: context) {
            return m
        } else if let m = try? Module.get(by: "kjv-str", from: context) {
            return m
        }
        return nil
    }
    
    func getVerses() -> ([NSAttributedString], [NSAttributedString]?) {
        fontSize = AppDelegate.plistManager.getFontSize()
        if module1 == nil {
            initMainModule()
        }
        if module2 == nil {
            initSecondModule()
        }
        var v1: [NSAttributedString] = []
        var v2: [NSAttributedString]?
        if var verses = chapter1?.verses?.array as? [Verse],
            verses.count > 0 {
            verses.sort { $0.number < $1.number }
            
            var attributed: [NSAttributedString] = []//verses.map { return $0.attributedCompound(size: fontSize) }
            for verse in verses {
                let attr = verse.attributedCompound(size: fontSize)
                if attr.strongNumbersAvailable {
                    attributed.append(attr.embedStrongs(to: AppDelegate.URLServerRoot + currentTestament + "/", using: fontSize, linking: true))
                } else {
                    attributed.append(attr)
                }
            }
            if let ranges = versesRanges {
                v1 = []
                for range in ranges {
                    for i in 0..<attributed.count {
                        if range.contains(i + 1) {
                            v1.append(attributed[i])
                        }
                    }
                }
            } else {
                v1 = attributed
            }
        }
        if var verses = chapter2?.verses?.array as? [Verse],
            verses.count > 0 {
            verses.sort { $0.number < $1.number }
//            let attributed = verses.map { return $0.attributedCompound(size: fontSize) }
            var attributed: [NSAttributedString] = []//verses.map { return $0.attributedCompound(size: fontSize) }
            for verse in verses {
                let attr = verse.attributedCompound(size: fontSize)
                if attr.strongNumbersAvailable {
                    attributed.append(attr.embedStrongs(to: AppDelegate.URLServerRoot + currentTestament + "/", using: fontSize, linking: true))
                } else {
                    attributed.append(attr)
                }
            }
            if let ranges = versesRanges {
                v2 = []
                for range in ranges {
                    for i in 0..<attributed.count {
                        if range.contains(i + 1) {
                        v2!.append(attributed[i])
                        }
                    }
                }
            } else {
                v2 = attributed
            }
        }
    
        return (v1, v2)
    }
    
    func getBooksTitles() -> [String]? {
        if let module = module1,
            let books = module.books?.array as? [Book] {
            return books.map {$0.name ?? ""}
        }
        return nil
    }
    
    func setBook(by title: String) -> Bool {
        let t = title.lowercased()
        if let books = module1.books?.array as? [Book] {
            for book in books {
                if let name = book.name?.lowercased(),
                    name.starts(with: t) {
                    bookNumber = Int(book.number)
                    chapterNumber = 1
                    versesRanges = nil
                    return true
                }
            }
        }
        if let books = module2?.books?.array as? [Book] {
            for book in books {
                if let name = book.name?.lowercased(),
                    name.starts(with: t) {
                    bookNumber = Int(book.number)
                    chapterNumber = 1
                    versesRanges = nil
                    return true
                }
            }
        }
        if let books = defaultModule?.books?.array as? [Book] {
            for book in books {
                if let name = book.name?.lowercased(),
                    name.starts(with: t) {
                    bookNumber = Int(book.number)
                    chapterNumber = 1
                    versesRanges = nil
                    return true
                }
            }
        }
        return false
    }
    
    
    func setChapter(number: Int) {
        if let book = book1, let ch = book.chapters?.array, ch.count >= number {
            chapterNumber = number
        }
        versesRanges = nil
    }

    override func next() {
        super.next()
        versesRanges = nil
    }
    
    override func previous() {
        super.previous()
        versesRanges = nil
    }
}

extension VerseManager {
    func setVerses(from strArray: [String]) {
        var verseRanges = [Range<Int>]()
        var pendingRange: Range<Int>? = nil
        for verse in strArray {
            if !("0"..."9" ~= verse[0]) {
                if let v = Int(verse[verse.index(after: verse.startIndex)...]) {
                    switch verse[0] {
                    case "-":
                        if pendingRange != nil {
                            pendingRange = Range(uncheckedBounds: (pendingRange!.lowerBound, v + 1))
                        } else {
                            pendingRange = Range(uncheckedBounds: (v, v + 1))
                        }
                    case ",",".":
                        if pendingRange != nil {
                            verseRanges.append(pendingRange!)
                        }
                        pendingRange = Range(uncheckedBounds: (v, v + 1))
                    default:break
                    }
                }
            } else {
                let v = Int(verse)!
                if pendingRange != nil {
                    verseRanges.append(pendingRange!)
                }
                pendingRange = Range(uncheckedBounds: (v,v + 1))
            }
        }
        if pendingRange != nil {
            verseRanges.append(pendingRange!)
        }
        versesRanges = verseRanges
    }
}
