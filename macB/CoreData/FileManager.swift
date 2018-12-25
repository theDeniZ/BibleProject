//
//  FileManager.swift
//  macB
//
//  Created by Denis Dobanda on 24.12.18.
//  Copyright © 2018 Denis Dobanda. All rights reserved.
//

import Cocoa
import FilesProvider

class FileManager: NSObject {

    var delegate: DownloadProgressDelegate?
    var countOfDirectoriesParsingAtOnce = 5
    
    private let documentProvider: LocalFileProvider
    private let rootPath: String
    private var countOfCurrentDirectories = 0
    
    
    init(_ path: String) {
        rootPath = path
        documentProvider = LocalFileProvider(baseURL: URL(fileURLWithPath: path))
        super.init()
    }
    
    func initiateParsing() {
        do {
            delegate?.downloadStarted(with: 1)
            try parseDirectory("/", being: 0)
            delegate?.downloadFinished()
        } catch ModuleParseError.moduleNotFound {
            parseMultipleDirectories("/")
        } catch {
            print("Unrecognized error \(error)")
        }
    }
    
    private func parseMultipleDirectories(_ path: String) {
        documentProvider.contentsOfDirectory(path: path) { (contents, error) in
            if error != nil {
                print(error!.localizedDescription)
            }
            let count = contents.count
            self.delegate?.downloadStarted(with: count)
            for i in 0..<count {
                let object = contents[i]
                if object.type == URLFileResourceType.directory {
                    Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (timer) in
                        print(object.name + " trying to parse: current \(self.countOfCurrentDirectories)")
                        if self.countOfCurrentDirectories < self.countOfDirectoriesParsingAtOnce {
                            print(object.name + " parsing: current \(self.countOfCurrentDirectories)")
                            self.countOfCurrentDirectories += 1
                            do {
                                try self.parseDirectory(path + object.name + "/", being: i) {
                                    if self.countOfCurrentDirectories == 0 {
                                        self.delegate?.downloadFinished()
                                    }
                                    print(object.name + " parsing finished: current \(self.countOfCurrentDirectories)")
                                    timer.invalidate()
                                }
                            } catch {
                                print(error)
                            }
                            timer.tolerance = .greatestFiniteMagnitude
                        }
                    }
//                    do {
//                        try self.parseDirectory(path + object.name + "/", being: i, counting: contents.count)
//                    } catch {
//                        print(error)
//                    }
                } else {
                    self.delegate?.downloadCompleted(with: false, at: object.name)
                }
            }
        }
    }
    
    private func parseDirectory(_ path: String, being: Int, completed: (() -> ())? = nil) throws {
        if documentProvider.fileManager.fileExists(atPath: rootPath + path + ININames.standart.rawValue) {
            let context = AppDelegate.context
            readINI(path, being: being, to: context, completed: completed)
        } else {
            self.countOfCurrentDirectories -= 1
            self.delegate?.downloadCompleted(with: false, at: path)
            completed?()
            throw ModuleParseError.moduleNotFound
        }
    }
    
    
    /*
        Reads .ini file and initiates parsing
        Runs in async
     */
    private func readINI(_ path: String, being: Int, to context: NSManagedObjectContext, completed: (() -> ())? = nil) {
        documentProvider.contents(path: path + ININames.standart.rawValue) { (data, err) in
            if err != nil {
                print(err!.localizedDescription)
                self.delegate?.downloadCompleted(with: false, at: path)
                self.countOfCurrentDirectories -= 1
                return
            }
            guard let data = data else {return}
            var written = false
            //        String(data: data, encoding: .isoLatin2)
            if let content = String(data: data, encoding: .iso2022JP) {
                written = self.parseINI(content: content.components(separatedBy: "\r\n"), in: path, to: context)
            } else if let content = String(data: data, encoding: .windowsCP1254) {
                written = self.parseINI(content: content.components(separatedBy: "\r\n"), in: path, to: context)
            }
//            print("Writing from '\(path)' finished with \(written ? "success" : "faliure")")
            
            // completed
            self.countOfCurrentDirectories -= 1
            completed?()
            
            if path != "/" {
                self.delegate?.downloadCompleted(with: written, at: path)
            } else {
                if let p = self.rootPath.split(separator: "/").map({String($0)}).last {
                    self.delegate?.downloadCompleted(with: written, at: p)
                } else {
                    self.delegate?.downloadCompleted(with: written, at: self.rootPath)
                }
            }
        }
    }
    

    /*
        Parsing module, described in .ini file
        Runs in sync
    */
    private func parseINI(content array: [String], in path: String, to context: NSManagedObjectContext) -> Bool {
        var bibleName: String?
        var bibleKey: String?
        var startingNumberForBooks = 1
        
        var booksInfo: [(path: String, name: String)] = []
        
        var pendingBook: String?
        for i in 0..<array.count {
            if array[i].matches("BibleName =[ ]?.*") {
                bibleName = array[i].capturedGroups(withRegex: "BibleName =[ ]?(.*)")?[0]
            } else if array[i].matches("BibleShortName =[ ]?.*") {
                bibleKey = array[i].capturedGroups(withRegex: "BibleShortName =[ ]?(.*)")?[0]
            } else if array[i].matches("OldTestament =[ ]?.*") {
                startingNumberForBooks =  array[i].capturedGroups(withRegex: "OldTestament =[ ]?(.*)")?[0] == "Y" ? 1 : 38
            } else if array[i].matches("PathName =[ ]?.*") {
                pendingBook = array[i].capturedGroups(withRegex: "PathName =[ ]?(.*)")?[0]
            } else if array[i].matches("FullName =[ ]?.*") {
                if let path = pendingBook,
                    let name = array[i].capturedGroups(withRegex: "FullName =[ ]?(.*)")?[0] {
                    booksInfo.append((path, name))
                    pendingBook = nil
                }
            }
        }
        // TODO: parse html next
        if let name = bibleName,
            let key = bibleKey{
            
            if let m = try? Module.get(by: key.lowercased(), from: context), let module = m {
                context.delete(module)
                try? context.save()
            }
            let module = Module(context: context)
            module.name = name
            module.key = key.lowercased()
            module.local = true
            
            let htmlParser = HTMLParser(rootPath + path, start: startingNumberForBooks, context: context)
            if htmlParser.parse(booksInfo, to: module) {
                do {
                    try context.save()
                    return true
                } catch {
                    print(error)
                }
            }
        }
        return false
    }
    
}


enum ModuleParseError: Error {
    case moduleNotFound
    case other(String)
}


enum ININames: String {
    case standart = "bibleqt.ini"
//    case uppercase = "BIBLEQT.INI"
//    case firstUpper = "Bibleqt.ini"
}
