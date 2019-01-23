//
//  Page.swift
//  macB
//
//  Created by Denis Dobanda on 20.01.19.
//  Copyright © 2019 Denis Dobanda. All rights reserved.
//

import Foundation
import CoreData

class Page: NSManagedObject {
    class func get(with number: Int, from book: SpiritBook, searching context: NSManagedObjectContext) throws -> Page? {
        let req: NSFetchRequest<Page> = Page.fetchRequest()
        req.predicate = NSPredicate(format: "number == %@ AND chapter.book == %@", argumentArray: [number, book])
        
        let match = try context.fetch(req)
        if match.count > 0 {
            assert(match.count == 1, "Assert error: Page.get - Database inconsistency")
            return match[0]
        }
        return nil
    }
}
