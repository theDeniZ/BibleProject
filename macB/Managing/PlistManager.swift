//
//  FileManager.swift
//  SplitB
//
//  Created by Denis Dobanda on 30.10.18.
//  Copyright © 2018 Denis Dobanda. All rights reserved.
//

import Cocoa
import FilesProvider

class PlistManager {
    
    var plistName = "UserSettings"
    var plistHandler: PlistHandler
    
    var isStrongsIsOn: Bool {
        var s = true
        plistHandler.get(to: &s, of: strongsKey)
        return s
    }
    
    private var plistPath: String?
    
    private let fontKey = "font size"
    private let chapterKey = "chapter"
    private let bookKey = "book"
    private let modulesKey = "modules"
    private let strongsKey = "strongsNumbers"
    private let sharingKey = "shared"
    private var spiritKey = "spirit"

    init() {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as NSArray
        let documentDirectory = paths[0] as! String
        let path = documentDirectory.appending("/" + plistName + ".plist")
        plistPath = path
        
        let fileManager = LocalFileProvider.init().fileManager
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
    
    func setStrong(on: Bool) {
        plistHandler.setValue(on, of: strongsKey)
    }
    
    func getSharedObjects() -> [String:String] {
        var obj: [String:String] = [:]
        plistHandler.get(to: &obj, of: sharingKey)
        return obj
    }
    
    func setShared(objects: [String:String]) {
        plistHandler.setValue(objects, of: sharingKey)
    }
    
    func setSpirit(indicies: [SpiritIndex]?) {
        if let array = indicies {
            var dict: [String:String] = [:]
            for ind in array {
                dict[ind.book] = "\(ind.chapter)"
            }
            plistHandler.setValue(dict, of: spiritKey)
        }
    }
    
    func getSpirit() -> [SpiritIndex]? {
        var dict: [String:String] = [:]
        plistHandler.get(to: &dict, of: spiritKey)
        if dict.count > 0 {
            var indices = [SpiritIndex]()
            for (key, value) in dict {
                if let n = Int(value) {
                    indices.append(SpiritIndex(book: key, chapter: n))
                }
            }
            return indices
        }
        return nil
    }
}
