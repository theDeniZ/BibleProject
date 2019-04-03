//
//  PreviewSpiritService.swift
//  OpenBible
//
//  Created by Denis Dobanda on 02.04.19.
//  Copyright © 2019 Denis Dobanda. All rights reserved.
//

import Foundation

class PreviewSpiritService: NSObject {
    
    private var manager = AppDelegate.spiritManager
    
    var modelVerseDelegate: ModelVerseDelegate {
        return manager
    }
    
    override var description: String {
        return manager.description
    }
    
    func changeChapter(to number: Int) {
        manager.setChapter(number: number)
    }
    func changeBook(by text: String) -> Bool {
        _=manager.set(book: text)
        return true
    }
    func setVerses(from array: [String]) {
//        manager.setVerses(from: array)
    }
    
    func getDataToPresent() -> [[Presentable]] {
        return [manager.presentableValue()]
    }
    func increment() {
//        manager.incrementChapter()
    }
    
    func decrement() {
//        manager.decrementChapter()
    }
    func addDelegate(_ del: ModelUpdateDelegate) {
        manager.delegate = del
    }
    
}
