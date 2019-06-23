//
//  PreviewModuleService.swift
//  OpenBible
//
//  Created by Denis Dobanda on 31.03.19.
//  Copyright © 2019 Denis Dobanda. All rights reserved.
//

import Foundation

class PreviewModuleService: NSObject {
    private var manager: VerseManager = AppDelegate.coreManager
    
    var modelVerseDelegate: ModelVerseDelegate {
        return manager
    }
    
    override var description: String {
        return manager.description
    }
    
    func changeChapter(to number: Int) {
        manager.changeChapter(to: number)
    }
    func changeBook(by text: String) -> Bool {
        return manager.changeBook(by: text)
    }
    func setVerses(from array: [String]) {
        manager.setVerses(from: array)
    }
    
    func getDataToPresent() -> [[Presentable]] {
        return manager.getVerses()
    }
    func increment() {
        manager.incrementChapter()
    }
    
    func decrement() {
        manager.decrementChapter()
    }
    func addDelegate(_ del: ModelUpdateDelegate) {
        manager.addDelegate(del)
    }
    
    func zoom(incrementingTo value: Double) {
        manager.scaleFont(to: value)
    }
    
}
