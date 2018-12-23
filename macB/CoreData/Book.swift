//
//  Book.swift
//  macB
//
//  Created by Denis Dobanda on 21.12.18.
//  Copyright © 2018 Denis Dobanda. All rights reserved.
//

import Foundation
import CoreData

class Book: NSManagedObject {
    class func create(in context: NSManagedObjectContext) -> Book {
        return Book(context: context)
    }
    
    class func create(from json: [String:Any], in context: NSManagedObjectContext) -> Book? {
        guard let num = json["book_nr"] as? Int,
            let chps = json["book"] as? [String:Any],
            let name = json["book_name"] as? String
            else {return nil}
        
        let book = Book(context: context)
        var chapters: [Chapter] = []
        book.name = name
        book.number = Int32(num)
        
        for index in 1...chps.count {
            if let j = chps["\(index)"] as? [String:Any],
                let chapter = Chapter.create(from: j, in: context) {
                chapters.append(chapter)
                chapter.book = book
            } else {
                context.delete(book)
                return nil
            }
        }
        book.chapters = NSOrderedSet(array: chapters)
        return book
    }
    
    class func isThere(with number: Int, in module: Module, _ context: NSManagedObjectContext) -> Bool {
        let fetch: NSFetchRequest<Book> = Book.fetchRequest()
        let predicate = NSPredicate(format: "number = %@ AND module = %@", argumentArray: [number, module])
        fetch.predicate = predicate
        
        do {
            let match = try context.fetch(fetch)
            if match.count > 0 {
                return true
            }
        } catch {
            print("Error: Book.isThereBook: \(error)")
        }
        return false
    }
    
    class func find(by regex: String, in context: NSManagedObjectContext) -> Int? {
        let fetch: NSFetchRequest<Book> = Book.fetchRequest()
        let predicate = NSPredicate(format: "name MATCHES %@", argumentArray: [regex])
        fetch.predicate = predicate
        
        do {
            let match = try context.fetch(fetch)
            if match.count > 0 {
                return Int(match[0].number)
            }
        } catch {
            print("Error: Book.isThereBook: \(error)")
        }
        return nil
    }
}
