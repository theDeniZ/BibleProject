//
//  Manager.swift
//  SplitB
//
//  Created by Denis Dobanda on 25.10.18.
//  Copyright © 2018 Denis Dobanda. All rights reserved.
//

import UIKit
import CoreData

class Manager {
    
    var context: NSManagedObjectContext!
    
    var module1: Module! {
        didSet {
            assertModuleConsistency()
        }
    }
    internal var module2: Module?
    
    var bookNumber: Int { didSet { write() } }
    var chapterNumber: Int { didSet { write() } }
    
    private var plistManager = PlistManager()
    private var timerToWrite: Timer?
    
    var book1: Book? {
        if let books = module1?.books?.array as? [Book] {
            let bookFiltered = books.filter { Int($0.number) == bookNumber }
            return bookFiltered.first
        }
        return nil
    }
    var book2: Book? {
        if let books = module2?.books?.array as? [Book] {
            let bookFiltered = books.filter { Int($0.number) == bookNumber }
            return bookFiltered.first
        }
        return nil
    }
    var chapter1: Chapter? {
        if let book = book1, let chapters = book.chapters?.array as? [Chapter] {
            let chaptersFiltered = chapters.filter { Int($0.number) == chapterNumber }
            return chaptersFiltered.first
        }
        return nil
    }
    var chapter2: Chapter? {
        if let book = book2, let chapters = book.chapters?.array as? [Chapter] {
            let chaptersFiltered = chapters.filter { Int($0.number) == chapterNumber }
            return chaptersFiltered.first
        }
        return nil
    }
    
    init(in context: NSManagedObjectContext) {
        self.context = context
        let last = plistManager.getCurrentBookAndChapterIndexes()
        bookNumber = last.0 > 0 ? last.0 : 1
        chapterNumber = last.1 > 0 ? last.1 : 1
        initMainModule()
        initSecondModule()
        assertModuleConsistency()
    }
    
    internal func initMainModule() {
        let m1 = plistManager.getPrimaryModule()
        if m1.count > 0 {
            if let modules = try? Module.getAll(from: context) {
                let filtered = modules.filter {$0.key == m1}
                if filtered.count > 0 {
                    module1 = filtered[0]
                }
            }
        }
        if module1 == nil, let modules = try? Module.getAll(from: context), modules.count > 0 {
            module1 = modules[0]
            bookNumber = 1
            chapterNumber = 1
        }
    }
    
    internal func initSecondModule() {
        let m2 = plistManager.getSecondaryModule()
        if m2.count > 0 {
            if let modules = try? Module.getAll(from: context) {
                let filtered = modules.filter {$0.key == m2}
                module2 = filtered.first
            }
        }
    }
    
    private func assertModuleConsistency() {
        if let module = module1,
            let books = module.books?.array as? [Book],
            books.count < bookNumber,
            books.count > 0 {
            bookNumber = Int(books[0].number)
            chapterNumber = 1
        }
    }
    
    func getAvailableModules(exceptFirst: Bool = false) -> [Module]? {
        do {
            var all = try Module.getAll(from: context)
            if exceptFirst, let m = module1 {
                all.removeAll(where: {$0.key == m.key})
            }
            return all
        } catch {
            print(error)
        }
        return nil
    }
    
    func getMainModuleKey() -> String? {
        return module1?.key
    }
    
    func getSecondaryModuleKey() -> String? {
        return module2?.key
    }
    
    func getModulesKey() -> (String?, String?) {
        return (getMainModuleKey(), getSecondaryModuleKey())
    }
    
    func setFirst(_ module: Module) {
        if module2?.key == module.key {
            module2 = module1
        }
        module1 = module
        plistManager.setPrimary(module: module.key ?? "")
    }
    
    func setSecond(_ module: Module?) {
        module2 = module
        plistManager.setSecondary(module: module?.key ?? "")
    }
    
    func getBooks() -> [Book]? {
        return (module1?.books?.array as? [Book])?.sorted(by: { (f, s) -> Bool in
            f.number < s.number
        })
    }
    
    func next() {
        if let book = book1, let chapters = book.chapters?.array as? [Chapter] {
            for chapter in chapters {
                if Int(chapter.number) == chapterNumber + 1 {
                    chapterNumber += 1
                    return
                }
            }
        }
        if let books = module1.books?.array as? [Book] {
            for book in books {
                if Int(book.number) == bookNumber + 1 {
                    bookNumber += 1
                    chapterNumber = 1
                    return
                }
            }
        }
    }
    
    func previous() {
        chapterNumber -= 1
        if chapterNumber == 0, bookNumber != 1, let books = module1.books?.array as? [Book] {
            for book in books {
                if Int(book.number) == bookNumber - 1 {
                    bookNumber -= 1
                    if let chapters = book.chapters?.array as? [Chapter] {
                        for chapter in chapters {
                            if Int(chapter.number) > chapterNumber {
                                chapterNumber = Int(chapter.number)
                            }
                        }
                        return
                    } else {
                        bookNumber += 1
                        chapterNumber += 1
                        return
                    }
                }
            }
            chapterNumber += 1
        }
        if (bookNumber == 1) {
            chapterNumber = 1
        }
        
    }

    func get1BookName() -> String {
        return book1?.name ?? ""
    }
    
    func getTwoStrings() -> ([NSAttributedString]?, [NSAttributedString]?) {
        if module1 == nil {
            initMainModule()
        }
        if module2 == nil {
            initSecondModule()
        }
        var s1: [NSAttributedString]? = [NSAttributedString(string:"Please, download available modules")]
        var s2: [NSAttributedString]? = nil
        if let chapter = chapter1, let verses = chapter.verses?.array as? [Verse] {
            s1 = []
            for verse in verses {
                s1!.append(verse.attributedCompound)
            }
        }
        if let chapter = chapter2, let verses = chapter.verses?.array as? [Verse] {
            s2 = []
            for verse in verses {
                s2!.append(verse.attributedCompound)
            }
        }
        return (s1, s2)
    }
    
    private func write() {
        timerToWrite?.invalidate()
        timerToWrite = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { [weak self] (t) in
            self?.plistManager.set(book: self!.bookNumber, chapter:self!.chapterNumber)
            if let ch = self?.chapter1 {
                History.add(to: self!.context, chapter: ch)
            }
            t.invalidate()
            self?.timerToWrite = nil
        }
    }
}
