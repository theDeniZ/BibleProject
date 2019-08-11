//
//  MenuService.swift
//  OpenBible
//
//  Created by Denis Dobanda on 26.03.19.
//  Copyright © 2019 Denis Dobanda. All rights reserved.
//

import Foundation

class MenuService: NSObject {
    
    var manager = MultipleVerseManager.shared
    
    var bookIndexPath: IndexPath {
        if manager.getBooks(from: 0)?.count == 66 {
            var index = manager.bibleIndex(for: 0).book - 1
            var section = 0
            if index >= 39 {
                section = 1
                index -= 39
            }
            return IndexPath(row: index, section: section)
        } else {
            return IndexPath(row: manager.bibleIndex(for: 0).book, section: 0)
        }
    }

    func getItemsToPresent() -> [[ListExpandablePresentable]] {
        if let books = manager.getBooks(from: 0) {
            if books.count == 66 {
                var old: [ListExpandablePresentable] = []
                var new: [ListExpandablePresentable] = []
                for i in 0..<39 {
                    old.append(ListExpandablePresentable(books[i].name ?? "", index: Int(books[i].number), count: books[i].chapters?.count ?? 0))
                }
                for i in 39..<books.count {
                    new.append(ListExpandablePresentable(books[i].name ?? "", index: Int(books[i].number), count: books[i].chapters?.count ?? 0))
                }
                return [old, new]
            } else {
                return [books.compactMap {ListExpandablePresentable($0.name ?? "", index: Int($0.number), count: $0.chapters?.count ?? 0)}]
            }
        }
        return []
    }
    
    func getKeysTitle() -> String {
        let modules = manager.getModulesKey()
        var title = modules.first ?? ""
        if modules.count > 1 {
            title += " +\(modules.count - 1)"
        }
        return title
    }
}
