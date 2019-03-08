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
}
