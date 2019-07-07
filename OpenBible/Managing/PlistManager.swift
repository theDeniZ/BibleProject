//
//  FileManager.swift
//  SplitB
//
//  Created by Denis Dobanda on 30.10.18.
//  Copyright © 2018 Denis Dobanda. All rights reserved.
//

import UIKit

class PlistManager {
    
    var plistName = "UserSettings"
    var plistHandler: PlistHandler
    
    private var plistPath: String?
    
    private let fontKey = "fontSize"
    private let indexKey = "bibleIndex"
    private let modulesKey = "modules"
    private let strongsKey = "strongs"
    private let portraitNumberKey = "portraitNumber"
    private var spiritKey = "spirit"
    
    private let bookKey = "bookIndex"
    private let chapterKey = "chapterIndex"
    private let verseKey = "versesRanges"
    
    var isStrongsOn: Bool {
        get {
            var isOn = true
            plistHandler.get(to: &isOn, of: strongsKey)
            return isOn
        }
        set {
            plistHandler.setValue(newValue, of: strongsKey)
        }
    }
    
    var portraitNumber: Int {
        get {
            var n = 2
            plistHandler.get(to: &n, of: portraitNumberKey)
            return n
        }
        set {
            plistHandler.setValue(newValue, of: portraitNumberKey)
        }
    }
    
    init() {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as NSArray
        let documentDirectory = paths[0] as! String
        let path = documentDirectory.appending("/" + plistName + ".plist")
        plistPath = path
        let fileManager = FileManager.default
        if(!fileManager.fileExists(atPath: path)) {
            if let bundlePath = Bundle.main.path(forResource: plistName, ofType: "plist") {
                do{
                    try fileManager.copyItem(atPath: bundlePath, toPath: path)
                }catch{
                    print("copy failure.")
                }
            }else{
                print("file myData.plist not found.")
            }
        }else{
//            print("file myData.plist already exits at path.")
        }
        plistHandler = PlistHandler(plistPath)
    }
    
    static var shared = PlistManager()
    
    func getCurrentBookAndChapterIndexes() -> (bookIndex: Int, chapterIndex: Int) {
        var bookIndex = 1
        var chapterIndex = 1
        plistHandler.get(to: &bookIndex, of: bookKey)
        plistHandler.get(to: &chapterIndex, of: chapterKey)
        return (bookIndex, chapterIndex)
    }
    
    func getBibleIndex() -> MultipleBibleIndex {
        var dict: [String: Any] = [:]
        plistHandler.get(to: &dict, of: indexKey)
        let index = MultipleBibleIndex()
        for key in dict.keys.sorted() {
            if let current = dict[key] as? [String: Any] {
                let book = current[bookKey] as? Int ?? 1
                let chapter = current[chapterKey] as? Int ?? 1
                var verses: [Range<Int>]? = nil
                if let data = current[verseKey] as? Data {
                    let decoder = JSONDecoder()
                    verses = try? decoder.decode([Range<Int>].self, from: data)
                }
                let item = BibleIndex(book: book, chapter: chapter, verses: verses)
                index.set(at: Int(key) ?? 0, bibleIndex: item)
            }
        }
        return index
    }
    
    func set(index: MultipleBibleIndex) {
        var dict: [String: Any] = [:]
        for key in index.keys {
            if let stored = index[key] {
                var bibleIndex = [String: Any]()
                bibleIndex[bookKey] = stored.book
                bibleIndex[chapterKey] = stored.chapter
                let encoder = JSONEncoder()
                bibleIndex[verseKey] = try? encoder.encode(stored.verses)

                dict["\(key)"] = bibleIndex
            }
        }
        plistHandler.setValue(dict, of: indexKey)
    }
    
    func set(book bookIndex: Int, chapter chapterIndex: Int, at index: String = "0") {
        var dict: [String: Any] = [:]
        plistHandler.get(to: &dict, of: indexKey)
        if var current = dict[index] as? [String: Any] {
            current[bookKey] = bookIndex
            current[chapterKey] = chapterIndex
        } else {
            dict[index] = [ bookKey : bookIndex, chapterKey : chapterIndex ]
        }
        plistHandler.setValue(dict, of: indexKey)
    }
    
    func set(book bookIndex: Int, at index: String = "0") {
        var dict: [String: Any] = [:]
        plistHandler.get(to: &dict, of: indexKey)
        if var current = dict[index] as? [String: Any] {
            current[bookKey] = bookIndex
        } else {
            dict[index] = [ bookKey : bookIndex ]
        }
        plistHandler.setValue(dict, of: indexKey)
    }
    
    func set(chapter chapterIndex: Int, at index: String = "0") {
        var dict: [String: Any] = [:]
        plistHandler.get(to: &dict, of: indexKey)
        if var current = dict[index] as? [String: Any] {
            current[chapterKey] = chapterIndex
        } else {
            dict[index] = [ chapterKey : chapterIndex ]
        }
        plistHandler.setValue(dict, of: indexKey)
    }
    
    func getAllModuleKeys() -> [String] {
        var modules: [String] = []
        plistHandler.get(to: &modules, of: modulesKey)
        return modules
    }
    
    func set(modules: [String]) {
        plistHandler.setValue(modules, of: modulesKey)
    }
    
    func set(module: String, at place: Int) {
        var modules: [String] = []
        plistHandler.get(to: &modules, of: modulesKey)
        if modules.count <= place {
            modules.append(module)
        } else if modules.count > place {
            modules[place] = module
        }
        plistHandler.setValue(modules, of: modulesKey)
    }
    
    func getFontSize() -> CGFloat {
        var s: CGFloat = 30.0
        plistHandler.get(to: &s, of: fontKey)
        return s
    }
    
    func setFont(size: CGFloat) {
        plistHandler.setValue(size.description, of: fontKey)
    }
    
    func setSpirit(_ index: SpiritIndex, at place: Int) {
        var dict: [String:String] = [:]
        plistHandler.get(to: &dict, of: spiritKey)
        dict["\(place)"] = "\(index.book)|\(index.chapter)"
        plistHandler.setValue(dict, of: spiritKey)
    }
    
    func getSpirit(from place: Int) -> SpiritIndex? {
        var dict: [String:String] = [:]
        plistHandler.get(to: &dict, of: spiritKey)
        if dict.index(forKey: "\(place)") != nil {
            let s = dict["\(place)"]!.split(separator: "|")
            return SpiritIndex.init(book: String(s[0]), chapter: Int(s[1]) ?? 0)
        }
        return nil
    }
    
}
