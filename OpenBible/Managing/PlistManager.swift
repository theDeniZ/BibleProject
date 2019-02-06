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
    private let primaryModuleKey = "lastPrimaryModule"
    private let secondaryModuleKey = "lastSecondaryModule"
    

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
    
    func getCurrentBookAndChapterIndexes() -> (Int, Int) {
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
    
    func getPrimaryModule() -> String {
        var m = ""
        plistHandler.get(to: &m, of: primaryModuleKey)
        return m
    }
    
    func getSecondaryModule() -> String {
        var m = ""
        plistHandler.get(to: &m, of: secondaryModuleKey)
        return m
    }
    
    func setPrimary(module: String) {
        plistHandler.setValue(module, of: primaryModuleKey)
    }

    func setSecondary(module: String) {
        plistHandler.setValue(module, of: secondaryModuleKey)
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
