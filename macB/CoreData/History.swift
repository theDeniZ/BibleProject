//
//  History.swift
//  macB
//
//  Created by Denis Dobanda on 21.12.18.
//  Copyright © 2018 Denis Dobanda. All rights reserved.
//

import Foundation
import CoreData

class History: NSManagedObject {
    
    class func getCount(from context: NSManagedObjectContext) -> Int {
        return (try? context.fetch(History.fetchRequest()).count) ?? 0
    }
    
    class func get(from context: NSManagedObjectContext) throws -> [History] {
        let request: NSFetchRequest <History> = History.fetchRequest()
        let sort = NSSortDescriptor(key: "added", ascending: false)
        request.sortDescriptors = [sort]
        
        do {
            let match = try context.fetch(request)
            if match.count > 20 {
                for i in 20..<match.count {
                    context.delete(match[i])
                }
                try? context.save()
            }
            return match
        } catch {
            throw error
        }
    }
    
    class func add(to context: NSManagedObjectContext, chapter: Chapter) {
        let request: NSFetchRequest <History> = History.fetchRequest()
        let predicate = NSPredicate(format: "chapter = %@", argumentArray: [chapter])
        request.predicate = predicate
        
        do {
            let match = try context.fetch(request)
            if match.count > 0 {
                match[0].added = Date()
                try? context.save()
                return
            }
        } catch {
            print(error)
        }
        
        let h = History(context: context)
        h.chapter = chapter
        h.added = Date()
        try? context.save()
    }
    
    class func clear(in context: NSManagedObjectContext) {
        let req: NSFetchRequest <History> = History.fetchRequest()
        if let all = try? context.fetch(req) {
            for obj in all {
                context.delete(obj)
            }
            try? context.save()
        }
    }
    
}
