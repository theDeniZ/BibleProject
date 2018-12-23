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
    var verses: [Int]?
}

class CoreManager: NSObject {
    
    var context: NSManagedObjectContext
    var activeModules: [Module]
    var currentIndex: BibleIndex
    
    private var delegates: [ModelUpdateDelegate]?
    
    init(_ context: NSManagedObjectContext) {
        self.context = context
        activeModules = []
        currentIndex = BibleIndex(book: 1, chapter: 1, verses: nil)
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
                                    for index in vs {
                                        let verse = verses.filter {$0.number == index}
                                        if verse.count > 0 {
                                            result.append(verse[0].attributedCompound)
                                        }
                                    }
                                    return result
                                } else {
                                    return verses.map {$0.attributedCompound}
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
        delegates?.forEach {$0.modelChanged()}
    }
}

// MARK: - Managing multiple modules

extension CoreManager {
    func getAllDownloadedModulesKey() -> [String] {
        return getAllDownloadedModules().map { $0.key ?? "" }
    }
    
    func getAllDownloadedModules() -> [Module] {
        return (try? Module.getAll(from: context)) ?? []
    }
    
    func getAllAvailableModules() -> [Module] {
        return getAllDownloadedModules().filter {!activeModules.contains($0)}
    }
    
    func getAllAvailableModulesKey() -> [String] {
        return getAllAvailableModules().map { $0.key ?? "" }
    }
    
    func setActive(_ module: Module, at place: Int) -> Module? {
        if place < activeModules.count {
            activeModules[place] = module
            return module
        }
        return nil
    }
    
    func setActive(_ key: String, at place: Int) -> Module? {
        if let m = try? Module.get(by: key, from: context), let module = m {
            return setActive(module, at: place)
        }
        return nil
    }
    
    func createNewActiveModule() -> (Module, Int)? {
        let available = getAllAvailableModules()
        if available.count > 0 {
            activeModules.append(available[0])
            return (available[0], activeModules.count - 1)
        }
        return nil
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

// MARK: - Change chapter

extension CoreManager {
    func changeChapter(to number: Int) {
        guard let book = book else {return}
        if Chapter.isThere(with: number, in: book, context) {
            currentIndex.chapter = number
            broadcastChanges()
        }
    }
    func incrementChapter() {
        guard let book = book else {return}
        if Chapter.isThere(with: currentIndex.chapter + 1, in: book, context) {
            currentIndex.chapter += 1
            broadcastChanges()
        } else if let m = mainModule,
            Book.isThere(with: currentIndex.book + 1, in: m, context) {
            currentIndex.book += 1
            currentIndex.chapter = 1
            broadcastChanges()
        }
    }
    func decrementChapter() {
        if currentIndex.chapter > 1 {
            currentIndex.chapter -= 1
            broadcastChanges()
        } else if let m = mainModule,
            Book.isThere(with: currentIndex.book - 1, in: m, context) {
            currentIndex.book -= 1
            currentIndex.chapter = book?.chapters?.array.count ?? 1
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
            while !("A"..."z" ~= name[i]) && i < name.count {
                i += 1
            }
            regex = "\(name[0])[.]?\\s*(?i)\(name[i..<name.count]).*"
        }
        if let n = Book.find(by: regex, in: context) {
            currentIndex.book = n
            currentIndex.chapter = 1
            broadcastChanges()
            return true
        }
        return false
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
