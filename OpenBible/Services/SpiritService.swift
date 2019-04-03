//
//  SpiritService.swift
//  OpenBible
//
//  Created by Denis Dobanda on 03.04.19.
//  Copyright © 2019 Denis Dobanda. All rights reserved.
//

import Foundation

class SpiritService: NSObject {
    
    let manager = AppDelegate.spiritManager
    
    func set(book withIndex: Int) {
        manager.setBook(withIndex: withIndex)
    }
    
    func set(chapter: Int) {
        manager.setChapter(number: chapter - 1)
    }
    
    func setDelegate(_ del: ModelUpdateDelegate) {
        manager.delegate = del
    }
}
