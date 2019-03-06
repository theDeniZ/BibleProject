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
    
    private let fontSizeKey = "font size"
    private let chapterKey = "chapter"
    private let bookKey = "book"
    private let modulesKey = "modules"
    private let strongsKey = "strongsNumbers"
    private var spiritKey = "spirit"
    private let menuKey = "menuIsOn"
    private let fontKey = "font"
    private let fontBoldKey = "fontBold"
    private let tooltipKey = "tooltip"

    var isTooltipOn: Bool {
        get {
            var o = false
            plistHandler.get(to: &o, of: tooltipKey)
            return o
        }
        set {
            plistHandler.setValue(newValue, of: tooltipKey)
        }
    }
    
    init() {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as NSArray
        let documentDirectory = paths[0] as! String
        let path = documentDirectory.appending("/" + plistName + ".plist")
        plistPath = path
        
        let fileManager = LocalFileProvider.init().fileManager
        if !fileManager.fileExists(atPath: path) {
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
        plistHandler.get(to: &s, of: fontSizeKey)
        return s
    }
    
    func setFont(size: CGFloat) {
        plistHandler.setValue(size.description, of: fontSizeKey)
    }
    
    func setStrong(on: Bool) {
        plistHandler.setValue(on, of: strongsKey)
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
    
    func isMenuOn() -> Bool {
        var isOn = false
        plistHandler.get(to: &isOn, of: menuKey)
        return isOn
    }
    
    func setMenu(isOn: Bool) {
        plistHandler.setValue(isOn, of: menuKey)
    }
    
    func getFont() -> String? {
        var s = ""
        plistHandler.get(to: &s, of: fontKey)
        return s.count > 0 ? s : nil
    }
    
    func setFont(named: String) {
        plistHandler.setValue(named, of: fontKey)
    }
    
    func getFontBold() -> String? {
        var s = ""
        plistHandler.get(to: &s, of: fontBoldKey)
        return s.count > 0 ? s : nil
    }
    
    func setFontBold(named: String) {
        plistHandler.setValue(named, of: fontBoldKey)
    }
}
