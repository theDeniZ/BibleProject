//
//  Chapter.swift
//  macB
//
//  Created by Denis Dobanda on 21.12.18.
//  Copyright © 2018 Denis Dobanda. All rights reserved.
//

import Foundation
import CoreData

class Chapter: NSManagedObject {
    class func create(in context: NSManagedObjectContext) -> Chapter {
        return Chapter(context: context)
    }
    
    class func create(from json: [String:Any], in context: NSManagedObjectContext) -> Chapter? {
        guard let num = json["chapter_nr"] as? Int, let vers = json["chapter"] as? [String:Any] else {return nil}
        let ch = Chapter(context: context)
        var verses: [Verse] = []
        ch.number = Int32(num)
        for index in 1...vers.count {
            if let j = vers["\(index)"] as? [String:Any],
                let verse = Verse.create(from: j, in: context) {
                verses.append(verse)
                verse.chapter = ch
            } else {
                context.delete(ch)
                return nil
            }
        }
        ch.verses = NSOrderedSet(array: verses)
        return ch
    }
}
