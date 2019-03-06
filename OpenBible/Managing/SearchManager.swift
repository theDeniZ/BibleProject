//
//  SearchManager.swift
//  OpenBible
//
//  Created by Denis Dobanda on 06.03.19.
//  Copyright © 2019 Denis Dobanda. All rights reserved.
//

import Foundation

class SearchManager: NSObject {
    
    var delegate: SearchManagerDelegate? { didSet { if finished {updateChanges()} } }
    
    private var results: [SearchResult]?
    private var error: Error?
    private var finished = false
    
    func engageSearch(with text: String) {
        let context = AppDelegate.context
        let modules = AppDelegate.manager.modules
        DispatchQueue.global(qos: .userInitiated).async {
            var verses: [Verse] = []
            do {
                verses = try Verse.find(containing: text, moduling: modules, in: context)
            } catch {
                self.error = error
            }
            if verses.count > 0 {
//                verses = verses.filterDuplicates { $0.chapter?.number == $1.chapter?.number && $0.chapter?.book?.number == $1.chapter?.book?.number && $0.number == $1.number }
                var results = [SearchResult]()
                for verse in verses {
                    let found = SearchResult()
                    found.text = verse.text ?? ""
                    found.title = verse.refference
                    let book = verse.chapter?.book?.number ?? 0
                    let chapter = verse.chapter?.number ?? 0
                    found.index = (Int(book), Int(chapter), Int(verse.number))
                    results.append(found)
                }
                self.results = results
            }
            self.updateChanges()
            self.finished = true
        }
    }
    
    private func updateChanges() {
        if error == nil {
            delegate?.searchManagerDidGetUpdate(results: results)
        } else {
            delegate?.searchManagerDidGetError(error: error!)
        }
    }
    
}
