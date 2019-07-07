//
//  MultipleCoreManager.swift
//  OpenBible
//
//  Created by Denis Dobanda on 07.07.19.
//  Copyright © 2019 Denis Dobanda. All rights reserved.
//

import Foundation
import CoreData

class MultipleVerseManager: NSObject {
    
    private var managers: [VerseManager]
    private var context: NSManagedObjectContext
    private var delegates: [ModelUpdateDelegate] = []
    
    private var multiple: MultipleBibleIndex
    
    init(context: NSManagedObjectContext) {
        self.context = context
        var managers = [VerseManager]()
        let multiple = PlistManager.shared.getBibleIndex()
        for key in multiple.keys.sorted() {
            if let index = multiple[key] {
                let manager = VerseManager(context)
                manager.index = index
                managers.append(manager)
            }
        }
        if managers.count == 0 {
            let manager = VerseManager(context)
            manager.index = BibleIndex(book: 1, chapter: 1, verses: nil)
            managers.append(manager)
        }
        self.managers = managers
        self.multiple = multiple
    }
    
    func getPresentable() -> CollectionPresentable {
        let presentable = CollectionPresentable()
        for manager in managers {
            let section = SectionPresentable()
            section.presentable = manager.getVerses()
            section.title = manager.description
            presentable.sections.append(section)
        }
        return presentable
    }
    
    func scaleFont(to value: Double) {
        managers.forEach { $0.scaleFont(to: value) }
    }
    
    func changeChapter(to number: Int) {
        if managers.count >= 1 {
            managers = [managers[0]]
            managers[0].changeChapter(to: number)
            multiple.set(new: [managers[0].index])
            PlistManager.shared.set(index: multiple)
        }
    }
    
    func incrementChapter() {
        if managers.count >= 1 {
            managers = [managers[0]]
            managers[0].incrementChapter()
            multiple.set(new: [managers[0].index])
            PlistManager.shared.set(index: multiple)
        }
    }
    
    func decrementChapter() {
        if managers.count >= 1 {
            managers = [managers[0]]
            managers[0].decrementChapter()
            multiple.set(new: [managers[0].index])
            PlistManager.shared.set(index: multiple)
        }
    }
    
    func changeBook(by text: String) -> Bool {
        if managers.count >= 1 {
            managers = [managers[0]]
            return managers[0].changeBook(by: text)
        }
        return false
    }
    
    func setVerses(from array: [String], at index: Int) {
        guard index < managers.count else { return }
        managers[index].setVerses(from: array)
        let index = MultipleBibleIndex()
        for i in 0..<managers.count {
            index.set(at: i, bibleIndex: managers[i].index)
        }
        PlistManager.shared.set(index: index)
    }
    
    func setIndices(_ indices: [BibleIndex]) {
        managers = []
        for _ in 0..<indices.count {
            managers.append(VerseManager(context))
        }
        delegates.forEach { del in managers.forEach { $0.addDelegate(del) } }
        
        for i in 0..<indices.count {
            managers[i].index = indices[i]
            managers[i].broadcastChanges()
        }
        multiple.set(new: indices)
        PlistManager.shared.set(index: multiple)
    }
    
    func addDelegate(_ delegate: ModelUpdateDelegate) {
        managers.forEach { $0.addDelegate(delegate) }
        delegates.append(delegate)
    }
    
    func bibleIndex(for index: Int) -> BibleIndex {
        guard index < managers.count else {
            if let last = managers.last?.index {
                return last
            } else {
                return BibleIndex(book: 1, chapter: 1, verses: nil)
            }
        }
        return managers[index].index
    }
    
    func bookIndex(for name: String) -> Int? {
        return VerseManager.bookIndex(for: name)
    }
    
}
