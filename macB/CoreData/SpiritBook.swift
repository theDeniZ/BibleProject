//
//  SpiritBook.swift
//  macB
//
//  Created by Denis Dobanda on 20.01.19.
//  Copyright © 2019 Denis Dobanda. All rights reserved.
//

import Foundation
import CoreData

class SpiritBook: NSManagedObject {
    class func getAll(from context: NSManagedObjectContext) throws -> [SpiritBook] {
        let request: NSFetchRequest<SpiritBook> = SpiritBook.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(key: "index", ascending: true),
            NSSortDescriptor(key: "lang", ascending: true)
        ]
        return try context.fetch(request)
    }
    
    class func get(by code: String, from context: NSManagedObjectContext) throws -> SpiritBook? {
        let request: NSFetchRequest<SpiritBook> = SpiritBook.fetchRequest()
        request.predicate = NSPredicate(format: "code = %@", argumentArray: [code])
        
        let matches = try context.fetch(request)
        if matches.count > 0 {
            assert(matches.count == 1, "SpiritBook: inconsistency error")
            return matches[0]
        }
        return nil
    }
    
    class func get(by index: Int, from context: NSManagedObjectContext) throws -> SpiritBook? {
        let request: NSFetchRequest<SpiritBook> = SpiritBook.fetchRequest()
        request.predicate = NSPredicate(format: "index = %@", argumentArray: [index])
        
        let matches = try context.fetch(request)
        if matches.count > 0 {
            assert(matches.count == 1, "SpiritBook: inconsistency error")
            return matches[0]
        }
        return nil
    }
    
    class func exists(with code: String, in context: NSManagedObjectContext) -> Bool {
        let request: NSFetchRequest<SpiritBook> = SpiritBook.fetchRequest()
        request.predicate = NSPredicate(format: "code = %@", argumentArray: [code])
        return (try? context.fetch(request).count > 0) ?? false
    }
    
    /// How many pages are asociated with this book
    ///
    /// - Parameter book: a SpiritBook object
    /// - Parameter context: NSManagedOblectContext
    /// - Returns: a pages count
    class func checkConsistency(of book: SpiritBook, in context: NSManagedObjectContext) -> Int {
        let req: NSFetchRequest<Page> = Page.fetchRequest()
        req.predicate = NSPredicate(format: "chapter.book = %@", argumentArray: [book])
        req.resultType = .countResultType
        do {
            let count = try context.count(for: req)
            return count
        } catch {
            print("SpiritBook CoreData checkConsistency error: \(error)")
        }
        return 0
    }
    
    /// How many pages are asociated with this book
    ///
    /// - Parameter code: a SpiritBook code
    /// - Parameter context: NSManagedOblectContext
    /// - Returns: a pages count
    class func checkConsistency(of code: String, in context: NSManagedObjectContext) -> Int {
        if let book = try? SpiritBook.get(by: code, from: context){
            return SpiritBook.checkConsistency(of: book, in: context)
        }
        return 0
    }
    
    class func from(_ sync: SyncSpiritBook, in context: NSManagedObjectContext) -> SpiritBook {
        let new = SpiritBook(context: context)
        new.index = Int32(sync.index)
        new.author = sync.author
        new.code = sync.code
        new.lang = sync.lang
        new.name = sync.name
        var chapters = [SpiritChapter]()
        for v in sync.chapters {
            let chapter = SpiritChapter.from(v, in: context)
            chapter.book = new
            chapters.append(chapter)
        }
        new.chapters = NSOrderedSet(array: chapters)
        return new
    }
    
    func hasPreword() -> Bool {
        return (chapters?.array as? [SpiritChapter])?[0].number == 0
    }
}
