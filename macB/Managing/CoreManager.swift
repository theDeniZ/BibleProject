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
    
    /// Subscript of manager with Int
    ///
    /// - Parameter n: index of needed Module to get Verses from
    ///
    /// - Returns: Array of verses texts ready to be shown
    subscript(n: Int) -> [NSAttributedString] {
        return getAttributedString(from: n, loadingTooltip: false)
    }
    
    func getAttributedString(from index: Int, loadingTooltip: Bool) -> [NSAttributedString] {
        if let chapter = chapter(index) {
            if let verses = chapter.verses?.array as? [Verse] {
                if let vs = currentIndex.verses {
                    var result = [NSAttributedString]()
                    for range in vs {
                        let versesFiltered = verses.filter {range.contains(Int($0.number))}
                        for verse in versesFiltered {
                            let attributedVerse = verse.attributedCompound(size: fontSize)
                            //check for strong's numbers
                            if attributedVerse.strongNumbersAvailable {
                                result.append(attributedVerse.embedStrongs(to: currentTestament, using: fontSize, linking: strongsNumbersIsOn, withTooltip: loadingTooltip))
                            } else {
                                result.append(attributedVerse)
                            }
                        }
                    }
                    return result
                } else {
                    if verses[0].attributedCompound.strongNumbersAvailable {
                        return verses.map {$0.attributedCompound.embedStrongs(to: currentTestament, using: fontSize, linking: strongsNumbersIsOn, withTooltip: loadingTooltip)}
                    }
                    return verses.map {$0.attributedCompound(size: fontSize)}
                }
            }
        }
        return []
    }
    
    /// Triggers method .modelChanged() at all delegates once
    /// after 0.1 seconds from the last call.
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
    
    /// Get all modules
    ///
    /// - Parameter local: if specified, return only local/non local modules
    /// - Returns: Array of modules. May be empty.
    func getAllDownloadedModules(_ local: Bool? = nil) -> [Module] {
        if let local = local {
            return (try? Module.getAll(from: context, local: local)) ?? []
        }
        return (try? Module.getAll(from: context)) ?? []
    }
    
    /// Get all modules, except that is currently in use
    ///
    /// - Returns: Array of modules. May be empty.
    func getAllAvailableModules() -> [Module] {
        return getAllDownloadedModules().filter {!activeModules.contains($0)}
    }
    
    /// Get all keys from available modules
    ///
    /// - Returns: Array of Strings - module keys
    func getAllAvailableModulesKey() -> [String] {
        return getAllAvailableModules().map { $0.key ?? "" }
    }
    
    /// Set a module to be used at a place
    ///
    /// - Parameters:
    ///   - module: Module instance
    ///   - place: index to place module to
    /// - Returns: same module if success, nil otherwise
    func setActive(_ module: Module, at place: Int) -> Module? {
        if place < activeModules.count, let k = module.key {
            activeModules[place] = module
            plistManager.set(module: k, at: place)
            return module
        }
        return nil
    }
    
    /// Set a module to be used at a place
    ///
    /// - Parameters:
    ///   - key: Key of a specific existing module
    ///   - place: index to place module to
    /// - Returns: placed module if success, nil otherwise
    func setActive(_ key: String, at place: Int) -> Module? {
        if let m = try? Module.get(by: key, from: context), let module = m {
            plistManager.set(module: key, at: place)
            return setActive(module, at: place)
        }
        return nil
    }
    
    /// Creates a place for the first available module and stores it there.
    ///
    /// - Returns: A pair of module and index of it in store if success, nil otherwise
    func createNewActiveModule() -> (Module, Int)? {
        let available = getAllAvailableModules()
        if available.count > 0, let key = available[0].key {
            activeModules.append(available[0])
            plistManager.set(module: key, at: activeModules.count - 1)
            return (available[0], activeModules.count - 1)
        }
        return nil
    }
    
    /// Remove stored module from place
    ///
    /// - Parameter index: index of module to be removed
    func removeModule(at index: Int) {
        if index < activeModules.count {
            activeModules.remove(at: index)
            plistManager.set(modules: activeModules.map{$0.key!})
        }
    }
}

// MARK: - Convenience

extension CoreManager {
    
    /// Either current book in use at first active module, or nil
    var book: Book? {
        do {
            if let module = mainModule,
                let b = try Book.get(by: currentIndex.book, concerning: module, in: context) {
                return b
            }
        } catch {
            print(error)
        }
        return nil
    }
    
    /// Either a book from a module with index, or nil
    ///
    /// - Parameter index: index of a module
    /// - Returns: a Book object or nil
    func book(_ index: Int) -> Book? {
        do {
            if let module = module(index),
                let b = try Book.get(by: currentIndex.book, concerning: module, in: context) {
                return b
            }
        } catch {
            print(error)
        }
        return nil
    }
    
    /// Either current chapter in current book from module at index, or nil
    ///
    /// - Parameter index: index of a module
    /// - Returns: a Chapter object or nil
    func chapter(_ index: Int) -> Chapter? {
        do {
            if let b = book(index),
                let c = try Chapter.get(by: currentIndex.chapter, concerning: b, in: context) {
                return c
            }
        } catch {
            print(error)
        }
        return nil
    }
    
    /// Either first active module, or nil
    var mainModule: Module? {
        if activeModules.count > 0 {
            return activeModules[0]
        }
        return nil
    }
    
    /// Either module at index, or nil
    ///
    /// - Parameter index: index of a moudle
    /// - Returns: a Module object or nil
    func module(_ index: Int) -> Module? {
        if activeModules.count > 0, activeModules.count > index {
            return activeModules[index]
        }
        return nil
    }
    
    /// Quick refference to current book and chapter
    override var description: String {
        if let b = book, let n = b.name {
            return "\(n) \(currentIndex.chapter)"
        }
        return ""
    }
}

// MARK: - Verse managing

extension CoreManager {
    /// Sets ranges of desired verses from an array of String
    ///
    /// - Parameter strArray: Array of String. Acceptable format for each String: "[-.,]?\\d+"
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
