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
    
}


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
