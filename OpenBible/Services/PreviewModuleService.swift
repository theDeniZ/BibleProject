//
//  PreviewModuleService.swift
//  OpenBible
//
//  Created by Denis Dobanda on 31.03.19.
//  Copyright © 2019 Denis Dobanda. All rights reserved.
//

import Foundation

class PreviewModuleService: NSObject {
    private var manager = MultipleVerseManager.shared
    
//    var modelVerseDelegate: ModelVerseDelegate {
//        return manager
//    }
    
    override var description: String {
        return manager.description
    }
    
    func changeChapter(to number: Int) {
        manager.changeChapter(to: number)
    }
    func changeBook(to index: Int) -> Bool {
        return manager.changeBook(to: index)
    }
    func changeBook(by text: String) -> Bool {
        return manager.changeBook(by: text)
    }
    func setVerses(from array: [String], at index: Int = 0) {
        manager.setVerses(from: array, at: index)
    }
    
    func setVerses(from dimentionalArray: [[String]]) {
        for i in 0..<dimentionalArray.count {
            setVerses(from: dimentionalArray[i], at: i)
        }
    }
    
    func setIndices(_ indices: [BibleIndex]) {
        manager.setIndices(indices)
    }
    
    func getDataToPresent() -> CollectionPresentable {
        return manager.getPresentable()
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
    
    func bibleIndex(for index: Int) -> BibleIndex {
        return manager.bibleIndex(for: index)
    }
    
    func bookIndex(for name: String) -> Int? {
        return manager.bookIndex(for: name)
    }
    
}
