//
//  SpiritMenuService.swift
//  OpenBible
//
//  Created by Denis Dobanda on 03.04.19.
//  Copyright © 2019 Denis Dobanda. All rights reserved.
//

import Foundation

class SpiritMenuService: NSObject {
    
    var manager = AppDelegate.spiritManager
    
    var bookIndexPath: IndexPath {
//        if manager.getBooks()?.count == 66 {
//            var index = manager.bookIndex
//            var section = 0
//            if index >= 39 {
//                section = 1
//                index -= 39
//            }
//            return IndexPath(row: index, section: section)
//        } else {
            return IndexPath(row: 0, section: 0)
//        }
    }
    
    func getItemsToPresent() -> [[ListExpandablePresentable]] {
        if let books = manager.getBooks() {
            return [books.compactMap {ListExpandablePresentable($0.name ?? "", index: Int($0.index), count: $0.chapters?.count ?? 0)}]
        }
        return []
    }
    
    func getKeysTitle() -> String {
        return "RU"
//        let modules = manager.getModulesKey()
//        var title = modules.first ?? ""
//        if modules.count > 1 {
//            title += " +\(modules.count - 1)"
//        }
//        return title
    }
}
