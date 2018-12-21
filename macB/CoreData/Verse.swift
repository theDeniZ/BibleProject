//
//  Verse.swift
//  macB
//
//  Created by Denis Dobanda on 21.12.18.
//  Copyright © 2018 Denis Dobanda. All rights reserved.
//

import Foundation
import CoreData

class Verse: NSManagedObject {
    class func create(in context: NSManagedObjectContext) -> Verse {
        return Verse(context: context)
    }
    
    class func create(from json: [String:Any], in context: NSManagedObjectContext) -> Verse? {
        guard let num = json["verse_nr"] as? Int, let t = json["verse"] as? String
            else {return nil}
        let v = Verse(context: context)
        v.number = Int32(num)
        v.text = t
        return v
    }
}
