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
        request.predicate = NSPredicate(format: "local = %@", argumentArray: [true])
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
}
