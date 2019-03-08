//
//  Module.swift
//  macB
//
//  Created by Denis Dobanda on 21.12.18.
//  Copyright © 2018 Denis Dobanda. All rights reserved.
//

import Foundation
import CoreData

class Module: NSManagedObject {
    class func create(in context: NSManagedObjectContext) -> Module {
        return Module(context: context)
    }
    
    class func getAll(from context: NSManagedObjectContext) throws -> [Module] {
        return try context.fetch(Module.fetchRequest())
    }
    
    class func getAll(from context: NSManagedObjectContext, local: Bool) throws -> [Module] {
        let request: NSFetchRequest<Module> = Module.fetchRequest()
        request.predicate = NSPredicate(format: "local = %@", argumentArray: [local])
        return try context.fetch(request)
    }
    
    class func get(by key: String, from context: NSManagedObjectContext) throws -> Module? {
        let request: NSFetchRequest <Module> = Module.fetchRequest()
        request.predicate = NSPredicate(format: "key = %@", argumentArray: [key.lowercased()])
        
        do {
            let match = try context.fetch(request)
            if match.count > 0 {
                assert(match.count == 1, "CoreData: Modules inconsistency")
                return match[0]
            }
        } catch {
            throw error
        }
        
        return nil
    }
    
    class func exists(key: String, in context: NSManagedObjectContext) -> Bool {
        let req: NSFetchRequest<Module> = Module.fetchRequest()
        req.predicate = NSPredicate(format: "key = %@", argumentArray: [key])
        return (try? context.fetch(req).count > 0) ?? false
    }
    
    class func create(from json: [String:Any], with name: String, in context: NSManagedObjectContext) -> Module? {
        guard let key = json["version_ref"] as? String,
            let jbooks = json["version"] as? [String:Any]
            else {return nil}
        let m = Module(context: context)
        m.key = key.lowercased()
        m.name = name
        var books: [Book] = []
        for (_, value) in jbooks {
            if let j = value as? [String:Any],
                let book = Book.create(from: j, in: context) {
                books.append(book)
                book.module = m
            } else {
                context.delete(m)
                return nil
            }
        }
        m.books = NSOrderedSet(array: books)
        return m
    }
    
    class func count(in context: NSManagedObjectContext) -> Int {
        return (try? context.fetch(Module.fetchRequest()).count) ?? 0
    }
    
    class func from(_ sync: SyncModule, in context: NSManagedObjectContext) -> Module {
        if let existed = try? Module.get(by: sync.key, from: context), existed != nil {
            context.delete(existed!)
        }
        let new = Module(context: context)
        new.key = sync.key
        new.name = sync.name
        var books: [Book] = []
        for b in sync.books {
            let book = Book.from(b, in:context)
            book.module = new
            books.append(book)
        }
        new.books = NSOrderedSet(array: books)
        return new
    }
    
    /// How many verses are asociated with this module
    ///
    /// - Parameter module: a Module object
    /// - Parameter context: NSManagedOblectContext
    /// - Returns: a verses count
    class func checkConsistency(of module: Module, in context: NSManagedObjectContext) -> Int {
        let req: NSFetchRequest<Verse> = Verse.fetchRequest()
        req.predicate = NSPredicate(format: "chapter.book.module = %@", argumentArray: [module])
        req.resultType = .countResultType
        do {
            let count = try context.count(for: req)
            return count
        } catch {
            print("Module CoreData checkConsistency error: \(error)")
        }
        return 0
    }
    
    /// How many verses are asociated with this module
    ///
    /// - Parameter key: a Module key
    /// - Parameter context: NSManagedOblectContext
    /// - Returns: a verses count
    class func checkConsistency(of key: String, in context: NSManagedObjectContext) -> Int {
        if let m = try? Module.get(by: key, from: context), let module = m {
            return Module.checkConsistency(of: module, in: context)
        }
        return 0
    }
}
