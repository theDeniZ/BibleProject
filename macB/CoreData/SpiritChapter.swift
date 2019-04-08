//
//  SpiritChapter.swift
//  macB
//
//  Created by Denis Dobanda on 20.01.19.
//  Copyright © 2019 Denis Dobanda. All rights reserved.
//

import Foundation
import CoreData

class SpiritChapter: NSManagedObject {
    class func from(_ sync: SyncSpiritChapter, in context: NSManagedObjectContext) -> SpiritChapter {
        let new = SpiritChapter(context: context)
        new.number = Int32(sync.number)
        new.index = Int32(sync.index)
        new.intro = sync.intro
        new.title = sync.title
        var pages = [Page]()
        for v in sync.pages {
            let page = Page.from(v, in: context)
            page.chapter = new
            pages.append(page)
        }
        new.pages = NSOrderedSet(array: pages)
        return new
    }
    
    class func find(number: Int, code: String, in context: NSManagedObjectContext) throws -> SpiritChapter? {
        let request: NSFetchRequest<SpiritChapter> = SpiritChapter.fetchRequest()
        request.predicate = NSPredicate(format: "number = %@ AND book.code = %@", argumentArray: [number, code])
        let match = try context.fetch(request)
        return match.first
    }
}
