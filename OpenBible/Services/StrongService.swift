//
//  StrongService.swift
//  OpenBible
//
//  Created by Denis Dobanda on 27.03.19.
//  Copyright © 2019 Denis Dobanda. All rights reserved.
//

import Foundation
import CoreData

class StrongService {
    
    private var identifier: String
    private var numbers: [Int]
    private var context: NSManagedObjectContext = AppDelegate.context
    
    init(_ parameters: [String]) {
        identifier = parameters[0]
        numbers = parameters[1].split(separator: "+").compactMap {Int(String($0))}
    }
    
    func getTitle() -> String {
        return "\(identifier) \(numbers.compactMap({String($0)}).joined(separator: ", "))"
    }
    
    func getText() -> String? {
        guard numbers.count > 0 else {return nil}
        var out = "\n"
        for number in numbers {
            if let strong = Strong.get(number, by: identifier, from: context) {
                if let org = strong.original {
                    out += "\(org)\n\n"
                }
                if let mean = strong.meaning {
                    out += "\(mean)\n\n"
                }
            }
        }
        return out
    }
}
