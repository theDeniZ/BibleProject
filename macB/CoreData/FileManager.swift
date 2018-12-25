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

    var context: NSManagedObjectContext
    var delegate: DownloadProgressDelegate?
    
    private let documentProvider: LocalFileProvider
    private let rootPath: String

    
    init(_ path: String, in context: NSManagedObjectContext) {
        rootPath = path
        documentProvider = LocalFileProvider(baseURL: URL(fileURLWithPath: path))
        self.context = context
        super.init()
    }
    
    func initiateParsing() {
        do {
            try parseDirectory("/", being: 0, counting: 1)
        } catch ModuleParseError.moduleNotFound {
            parseMultipleDirectories("/")
        } catch {
            print("Unrecognized error \(error)")
        }
    }
    
    private func parseDirectory(_ path: String, being: Int, counting: Int) throws {
        if documentProvider.fileManager.fileExists(atPath: rootPath + path + ININames.standart.rawValue) {
            readINI(path, being: being, counting: counting)
        } else {
            throw ModuleParseError.moduleNotFound
        }
    }
    
    private func parseMultipleDirectories(_ path: String) {
        documentProvider.contentsOfDirectory(path: path) { (contents, error) in
            if error != nil {
                print(error!.localizedDescription)
            }
            for i in 0..<contents.count {
                let object = contents[i]
                if object.type == URLFileResourceType.directory {
                    do {
                        try self.parseDirectory(path + object.name + "/", being: i, counting: contents.count)
                    } catch {
                        print(error)
                    }
                }
            }

        }
    }
    
    private func readINI(_ path: String, being: Int, counting: Int) {
        documentProvider.contents(path: path + ININames.standart.rawValue) { (data, err) in
            if err != nil {
                print(err!.localizedDescription)
                return
            }
            guard let data = data else {return}
            var written = false
            //        String(data: data, encoding: .isoLatin2)
            if let content = String(data: data, encoding: .utf8) {
                written = self.parseINI(content: content.components(separatedBy: "\r\n"), in: path)
            } else if let content = String(data: data, encoding: .windowsCP1254) {
                written = self.parseINI(content: content.components(separatedBy: "\r\n"), in: path)
            }
//            print("Writing from '\(path)' finished with \(written ? "success" : "faliure")")
            self.delegate?.downloadCompleted(with: written, at: being + 1, of: counting)
        }
    }

    
    private func parseINI(content array: [String], in path: String) -> Bool {
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
            
            // TODO: remove in case of existing
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
