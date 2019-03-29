//
//  VerseService.swift
//  OpenBible
//
//  Created by Denis Dobanda on 26.03.19.
//  Copyright © 2019 Denis Dobanda. All rights reserved.
//

import Foundation

class VerseService: NSObject {
    
    func changeChapter(to number: Int) {
        AppDelegate.coreManager.changeChapter(to: number)
    }
    
    func changeBook(to number: Int) {
        AppDelegate.coreManager.changeBook(to: number)
    }
    
}
