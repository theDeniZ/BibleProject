//
//  MenuService.swift
//  OpenBible
//
//  Created by Denis Dobanda on 26.03.19.
//  Copyright © 2019 Denis Dobanda. All rights reserved.
//

import Foundation

class MenuService: NSObject {
    var bookIndex: Int {
        return AppDelegate.coreManager.bookIndex
    }
    
    func getBooksToPresent() -> [Book] {
        return AppDelegate.coreManager.getBooks() ?? []
    }
    
    func getKeysTitle() -> String {
        let modules = AppDelegate.coreManager.getModulesKey()
        var title = modules.first ?? ""
        if modules.count > 1 {
            title += " +\(modules.count - 1)"
        }
        return title
    }
}
