//
//  CoreManager.swift
//  OpenBible
//
//  Created by Denis Dobanda on 13.03.19.
//  Copyright © 2019 Denis Dobanda. All rights reserved.
//

import Foundation
import CoreData

struct BibleIndex {
    var book, chapter: Int
    var verses: [Range<Int>]?
}

protocol ModelUpdateDelegate {
    var hashValue: Int {get}
    func modelChanged(_ fully: Bool)
}

class CoreManager: NSObject {
    
    var context: NSManagedObjectContext
    
    var index: BibleIndex
    var currentTestament: String {
        return index.book <= 39 ? StrongId.oldTestament : StrongId.newTestament
    }
    var modules: [Module] {
        return activeModules
    }
    var bookIndex: Int {
        return index.book
    }
    var verses: [Range<Int>]? {
        return index.verses
    }
    
    private var activeModules: [Module]
    private var delegates: [ModelUpdateDelegate]?
    private var timings: Timer?
    
    init(_ context: NSManagedObjectContext) {
        self.context = context
        activeModules = []
        let modules = PlistManager.shared.getAllModuleKeys()
        for module in modules {
            if let m = try? Module.get(by: module, from: context), m != nil {
                activeModules.append(m!)
            }
        }
        let index = PlistManager.shared.getCurrentBookAndChapterIndexes()
        self.index = BibleIndex(book: index.bookIndex, chapter: index.chapterIndex, verses: nil)
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
        return []
    }
    
    /// Triggers method .modelChanged() at all delegates once
    /// after 0.1 seconds from the last call.
    internal func broadcastChanges() {
        timings?.invalidate()
        timings = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { (t) in
            self.delegates?.forEach {$0.modelChanged(false)}
            t.invalidate()
        }
        timings?.fire()
    }
    
    func update(_ full: Bool = false) {
        var mods = [Module]()
        for module in activeModules {
            if Module.exists(key: module.key!, in: context) {
                mods.append(module)
            }
        }
        if activeModules.count == 0 {
            activeModules.append(try! Module.get(by: "kjv", from: context)!)
        }
        activeModules = mods
        PlistManager.shared.set(modules: activeModules.map{$0.key!})
        delegates?.forEach {$0.modelChanged(full)}
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
            PlistManager.shared.set(module: k, at: place)
            broadcastChanges()
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
            PlistManager.shared.set(module: key, at: place)
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
            PlistManager.shared.set(module: key, at: activeModules.count - 1)
            broadcastChanges()
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
            PlistManager.shared.set(modules: activeModules.map{$0.key!})
            broadcastChanges()
        }
    }
    
    /// Insert a module to a needed place
    ///
    /// - Parameters:
    ///   - module: a Module instance
    ///   - position: a place to insert into
    func insert(_ module: Module, at position: Int) {
        activeModules.insert(module, at: position)
        PlistManager.shared.set(modules: activeModules.map{$0.key!})
        broadcastChanges()
    }
    
    /// Insert a module to a needed place
    ///
    /// - Parameters:
    ///   - module: a Module key
    ///   - position: a place to insert into
    func insert(_ module: String, at position: Int) {
        activeModules.insert(try! Module.get(by: module, from: context)!, at: position)
        PlistManager.shared.set(modules: activeModules.map{$0.key!})
        broadcastChanges()
    }
    
    func swapModulesAt(_ i: Int, _ j: Int) {
        activeModules.swapAt(i, j)
        PlistManager.shared.set(modules: activeModules.map{$0.key!})
        broadcastChanges()
    }
}

// MARK: - Convenience

extension CoreManager {
    
    /// Either current book in use at first active module, or nil
    var book: Book? {
        do {
            if let module = mainModule,
                let b = try Book.get(by: index.book, concerning: module, in: context) {
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
                let b = try Book.get(by: self.index.book, concerning: module, in: context) {
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
                let c = try Chapter.get(by: self.index.chapter, concerning: b, in: context) {
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
            return "\(n) \(index.chapter)"
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
        index.verses = getVerseRanges(from: strArray)
        broadcastChanges()
    }
}

// MARK: - Change chapter

extension CoreManager {
    func changeChapter(to number: Int) {
        guard let book = book else {return}
        if Chapter.isThere(with: number, in: book, context) {
            index.chapter = number
            PlistManager.shared.set(chapter: number)
            index.verses = nil
            broadcastChanges()
        }
    }
    func incrementChapter() {
        guard let book = book else {return}
        if Chapter.isThere(with: index.chapter + 1, in: book, context) {
            index.chapter += 1
            PlistManager.shared.set(chapter: index.chapter)
            index.verses = nil
            broadcastChanges()
        } else if let m = mainModule,
            Book.isThere(with: index.book + 1, in: m, context) {
            index.book += 1
            index.chapter = 1
            PlistManager.shared.set(chapter: 1)
            PlistManager.shared.set(book: index.book)
            index.verses = nil
            broadcastChanges()
        }
    }
    func decrementChapter() {
        if index.chapter > 1 {
            index.chapter -= 1
            PlistManager.shared.set(chapter: index.chapter)
            index.verses = nil
            broadcastChanges()
        } else if let m = mainModule,
            Book.isThere(with: index.book - 1, in: m, context) {
            index.book -= 1
            index.chapter = book?.chapters?.array.count ?? 1
            PlistManager.shared.set(chapter: index.chapter)
            PlistManager.shared.set(book: index.book)
            index.verses = nil
            broadcastChanges()
        }
    }
}

// MARK: Change Book

extension CoreManager {
    func changeBook(to number: Int) {
        guard let module = mainModule else {return}
        if Book.isThere(with: number, in: module, context) {
            index.book = number
            index.chapter = 1
            PlistManager.shared.set(chapter: 1)
            PlistManager.shared.set(book: number)
            index.verses = nil
            broadcastChanges()
        }
    }
    func incrementBook() {
        changeBook(to: index.book + 1)
    }
    func decrementBook() {
        changeBook(to: index.book - 1)
    }
    
    func changeBook(by name: String) -> Bool {
        if let n = CoreManager.bookIndex(for: name) {
            index.book = n
            index.chapter = 1
            PlistManager.shared.set(chapter: 1)
            PlistManager.shared.set(book: n)
            index.verses = nil
            broadcastChanges()
            return true
        }
        return false
    }
    
    static func bookIndex(for name: String) -> Int? {
        var regex = "(?i)\(name).*"
        if "0"..."9" ~= name[0] {
            var i = 1
            while i < name.count && !String(name[i]).matches("\\w"){
                i += 1
            }
            regex = "\(name[0])[.]?\\s*(?i)\(name[i..<name.count]).*"
        }
        return Book.find(by: regex, in: AppDelegate.context)
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
