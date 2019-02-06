//
//  CoreSyncManager.swift
//  OpenBible
//
//  Created by Denis Dobanda on 25.01.19.
//  Copyright © 2019 Denis Dobanda. All rights reserved.
//

import Foundation
import CoreData

class CoreSyncManager: NSObject {
    
//    var context: NSManagedObjectContext = AppDelegate.context
    
    private var savedData: [Data]? = nil
    
    func add(_ data: Data) {
        if savedData != nil {
            savedData!.append(data)
        } else {
            savedData = [data]
        }
    }
    
    func parseStrongs(_ type: String) -> Bool {
        guard let savedData = savedData else {return false}
        let data = Data.from(chunks: savedData)
        self.savedData = nil
        let context = AppDelegate.context
        do {
            NSKeyedUnarchiver.setClass(SyncStrong.self, forClassName: "macB.SyncStrong")
            let obj = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data)
            if let parsedArray = obj as? [SyncStrong] {
                for parsed in parsedArray {
                    let strong = Strong(context: context)
                    strong.meaning = parsed.meaning
                    strong.number = Int32(parsed.number)
                    strong.original = parsed.original
                    strong.type = type
                }
                print("parsed \(parsedArray.count) \(type) objects")
                do {
                    try context.save()
                    return true
                } catch {
                    print(error)
                    return false
                }
            }
        } catch {
            print(error)
        }
        return false
    }
    
    func parseModule() -> Bool {
        guard let savedData = savedData else {return false}
        let data = Data.from(chunks: savedData)
        self.savedData = nil
        let context = AppDelegate.context
        NSKeyedUnarchiver.setClass(SyncModule.self, forClassName: "macB.SyncModule")
        NSKeyedUnarchiver.setClass(SyncBook.self, forClassName: "macB.SyncBook")
        NSKeyedUnarchiver.setClass(SyncChapter.self, forClassName: "macB.SyncChapter")
        NSKeyedUnarchiver.setClass(SyncVerse.self, forClassName: "macB.SyncVerse")
        do {
            let obj = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as! SyncModule
            let module = Module(context: context)
            module.key = obj.key
            module.name = obj.name
            module.local = obj.local
            var books = [Book]()
            for boo in obj.books {
                let book = Book(context: context)
                book.number = Int32(boo.number)
                book.name = boo.name
                var chapters = [Chapter]()
                for cha in boo.chapters {
                    let chapter = Chapter(context: context)
                    chapter.number = Int32(cha.number)
                    var verses = [Verse]()
                    for ver in cha.verses {
                        let verse = Verse(context: context)
                        verse.number = Int32(ver.number)
                        verse.text = ver.text
                        verses.append(verse)
                    }
                    chapter.verses = NSOrderedSet(array: verses)
                    chapters.append(chapter)
                }
                book.chapters = NSOrderedSet(array: chapters)
                books.append(book)
            }
            module.books = NSOrderedSet(array: books)
            
            do {
                try context.save()
                return true
            } catch {
                print(error)
                return false
            }
            
        } catch {
            print(error)
        }
        return false
    }
}
