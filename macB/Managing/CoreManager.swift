//
//  CoreManager.swift
//  macB
//
//  Created by Denis Dobanda on 23.12.18.
//  Copyright © 2018 Denis Dobanda. All rights reserved.
//

import Foundation
import CoreData

struct BibleIndex {
    var book, chapter: Int
    var verses: [Range<Int>]?
}

class CoreManager: NSObject {
    
    var context: NSManagedObjectContext
    var activeModules: [Module]
    var currentIndex: BibleIndex
    var fontSize: CGFloat
    var plistManager: PlistManager { return AppDelegate.plistManager }
    var strongsNumbersIsOn: Bool = true {didSet {plistManager.setStrong(on: strongsNumbersIsOn);broadcastChanges()}}
    
    var currentTestament: String {
        return currentIndex.book <= 39 ? StrongId.oldTestament : StrongId.newTestament
    }
    
    private var delegates: [ModelUpdateDelegate]?
    private var timings: Timer?
    
    init(_ context: NSManagedObjectContext) {
        self.context = context
        activeModules = []
        let modules = AppDelegate.plistManager.getAllModuleKeys()
        for module in modules {
            if let m = try? Module.get(by: module, from: context), m != nil {
                activeModules.append(m!)
            }
        }
        let index = AppDelegate.plistManager.getCurrentBookAndChapterIndexes()
        currentIndex = BibleIndex(book: index.bookIndex, chapter: index.chapterIndex, verses: nil)
        fontSize = AppDelegate.plistManager.getFontSize()
        strongsNumbersIsOn = AppDelegate.plistManager.isStrongsIsOn
        super.init()
    }
    
    subscript(n: Int) -> [NSAttributedString] {

        if n < activeModules.count {
            let module = activeModules[n]
            if let books = module.books?.array as? [Book] {
                let filteredBook = books.filter {$0.number == currentIndex.book}
                if filteredBook.count > 0 {
                    let book = filteredBook[0]
                    if let chapters = book.chapters?.array as? [Chapter] {
                        let filteredChapter = chapters.filter {$0.number == currentIndex.chapter}
                        if filteredChapter.count > 0 {
                            let chapter = filteredChapter[0]
                            if let verses = chapter.verses?.array as? [Verse] {
                                if let vs = currentIndex.verses {
                                    var result = [NSAttributedString]()
                                    for range in vs {
                                        let versesFiltered = verses.filter {range.contains(Int($0.number))}
                                        for verse in versesFiltered {
                                            let attributedVerse = verse.attributedCompound(size: fontSize)
                                            //check for strong's numbers
                                            if attributedVerse.strongNumbersAvailable {
                                                result.append(attributedVerse.embedStrongs(to: AppDelegate.URLServerRoot + currentTestament + "/", using: fontSize, linking: strongsNumbersIsOn))
                                            } else {
                                                result.append(attributedVerse)
                                            }
                                        }
                                    }
                                    return result
                                } else {
                                    if verses[0].attributedCompound.strongNumbersAvailable {
                                        return verses.map {$0.attributedCompound.embedStrongs(to: AppDelegate.URLServerRoot + currentTestament + "/", using: fontSize, linking: strongsNumbersIsOn)}
                                    }
                                    return verses.map {$0.attributedCompound(size: fontSize)}
                                }
                            }
                        }
                    }
                }
            }
        }
        return []
        
    }
    
    func broadcastChanges() {
        timings?.invalidate()
        timings = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { (t) in
            self.delegates?.forEach {$0.modelChanged()}
            t.invalidate()
        }
    }

}

// MARK: - Managing multiple modules

extension CoreManager {
    func getAllDownloadedModulesKey(_ local: Bool? = nil) -> [String] {
        return getAllDownloadedModules().map { $0.key ?? "" }
    }
    
    func getAllDownloadedModules(_ local: Bool? = nil) -> [Module] {
        if let local = local {
            return (try? Module.getAll(from: context, local: local)) ?? []
        }
        return (try? Module.getAll(from: context)) ?? []
    }
    
    func getAllAvailableModules() -> [Module] {
        return getAllDownloadedModules().filter {!activeModules.contains($0)}
    }
    
    func getAllAvailableModulesKey() -> [String] {
        return getAllAvailableModules().map { $0.key ?? "" }
    }
    
    func setActive(_ module: Module, at place: Int) -> Module? {
        if place < activeModules.count, let k = module.key {
            activeModules[place] = module
            plistManager.set(module: k, at: place)
            return module
        }
        return nil
    }
    
    func setActive(_ key: String, at place: Int) -> Module? {
        if let m = try? Module.get(by: key, from: context), let module = m {
            plistManager.set(module: key, at: place)
            return setActive(module, at: place)
        }
        return nil
    }
    
    func createNewActiveModule() -> (Module, Int)? {
        let available = getAllAvailableModules()
        if available.count > 0, let key = available[0].key {
            activeModules.append(available[0])
            plistManager.set(module: key, at: activeModules.count - 1)
            return (available[0], activeModules.count - 1)
        }
        return nil
    }
    
    func removeModule(at index: Int) {
        if index < activeModules.count {
            activeModules.remove(at: index)
            plistManager.set(modules: activeModules.map{$0.key!})
        }
    }
}

// MARK: - String convertable convenience

extension CoreManager {
    
    var book: Book? {
        if activeModules.count > 0,
            let f = activeModules[0].books?.array as? [Book] {
            let filter = f.filter {$0.number == currentIndex.book}
            if filter.count > 0 {
                return filter[0]
            }
        }
        return nil
    }
    var mainModule: Module? {
        if activeModules.count > 0 {
            return activeModules[0]
        }
        return nil
    }
    
    override var description: String {
        if let b = book, let n = b.name {
            return "\(n) \(currentIndex.chapter)"
        }
        return ""
    }
}

// MARK: - Verse managing

extension CoreManager {
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
        currentIndex.verses = verseRanges
        broadcastChanges()
    }
}

// MARK: - Change chapter

extension CoreManager {
    func changeChapter(to number: Int) {
        guard let book = book else {return}
        if Chapter.isThere(with: number, in: book, context) {
            currentIndex.chapter = number
            plistManager.set(chapter: number)
            currentIndex.verses = nil
            broadcastChanges()
        }
    }
    func incrementChapter() {
        guard let book = book else {return}
        if Chapter.isThere(with: currentIndex.chapter + 1, in: book, context) {
            currentIndex.chapter += 1
            plistManager.set(chapter: currentIndex.chapter)
            currentIndex.verses = nil
            broadcastChanges()
        } else if let m = mainModule,
            Book.isThere(with: currentIndex.book + 1, in: m, context) {
            currentIndex.book += 1
            currentIndex.chapter = 1
            plistManager.set(chapter: 1)
            plistManager.set(book: currentIndex.book)
            currentIndex.verses = nil
            broadcastChanges()
        }
    }
    func decrementChapter() {
        if currentIndex.chapter > 1 {
            currentIndex.chapter -= 1
            plistManager.set(chapter: currentIndex.chapter)
            currentIndex.verses = nil
            broadcastChanges()
        } else if let m = mainModule,
            Book.isThere(with: currentIndex.book - 1, in: m, context) {
            currentIndex.book -= 1
            currentIndex.chapter = book?.chapters?.array.count ?? 1
            plistManager.set(chapter: currentIndex.chapter)
            plistManager.set(book: currentIndex.book)
            currentIndex.verses = nil
            broadcastChanges()
        }
    }
}

// MARK: Change Book

extension CoreManager {
    func changeBook(to number: Int) {
        guard let module = mainModule else {return}
        if Book.isThere(with: number, in: module, context) {
            currentIndex.book = number
            currentIndex.chapter = 1
            plistManager.set(chapter: 1)
            plistManager.set(book: number)
            currentIndex.verses = nil
            broadcastChanges()
        }
    }
    func incrementBook() {
        changeBook(to: currentIndex.book + 1)
    }
    func decrementBook() {
        changeBook(to: currentIndex.book - 1)
    }
    
    func changeBook(by name: String) -> Bool {
        var regex = "(?i)\(name).*"
        if "0"..."9" ~= name[0] {
            var i = 1
            while i < name.count && !String(name[i]).matches("\\w"){
                i += 1
            }
            regex = "\(name[0])[.]?\\s*(?i)\(name[i..<name.count]).*"
        }
        if let n = Book.find(by: regex, in: context) {
            currentIndex.book = n
            currentIndex.chapter = 1
            plistManager.set(chapter: 1)
            plistManager.set(book: n)
            currentIndex.verses = nil
            broadcastChanges()
            return true
        }
        return false
    }
}

// MARK: Font

extension CoreManager {
    func incrementFont() {
        fontSize += 1.0
        broadcastChanges()
        plistManager.setFont(size: fontSize)
    }
    func decrementFont() {
        fontSize -= 1.0
        broadcastChanges()
        plistManager.setFont(size: fontSize)
    }
}

// MARK: Concerning Delegates

extension CoreManager {
    func addDelegate(_ obj: ModelUpdateDelegate) {
        if delegates == nil {
            delegates = [obj]
        } else {
            delegates!.append(obj)
        }
    }
    
    func removeDelegate(_ obj: ModelUpdateDelegate) {
        if delegates != nil, delegates!.count > 0 {
            delegates!.removeAll {$0.hashValue == obj.hashValue}
            if delegates!.count == 0 {
                delegates = nil
            }
        }
    }
}
