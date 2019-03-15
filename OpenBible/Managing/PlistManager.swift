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
    private let bookKey = "lastBookIndex"
    private let chapterKey = "lastChapterIndex"
    private let modulesKey = "modules"
    private let strongsKey = "strongs"
    private let portraitNumberKey = "portraitNumber"
    
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
    
    func getCurrentBookAndChapterIndexes() -> (bookIndex: Int, chapterIndex: Int) {
        var bookIndex = 1
        var chapterIndex = 1
        plistHandler.get(to: &bookIndex, of: bookKey)
        plistHandler.get(to: &chapterIndex, of: chapterKey)
        return (bookIndex, chapterIndex)
    }
    
    func set(book bookIndex: Int, chapter chapterIndex: Int) {
        plistHandler.setValue(bookIndex, of: bookKey)
        plistHandler.setValue(chapterIndex, of: chapterKey)
    }
    
    func set(book bookIndex: Int) {
        plistHandler.setValue(bookIndex, of: bookKey)
    }
    
    func set(chapter chapterIndex: Int) {
        plistHandler.setValue(chapterIndex, of: chapterKey)
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
    
    
}
