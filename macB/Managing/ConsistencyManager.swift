//
//  ConsistencyManager.swift
//  macB
//
//  Created by Denis Dobanda on 07.03.19.
//  Copyright © 2019 Denis Dobanda. All rights reserved.
//

import Foundation
import CoreData

class ConsistencyManager: NSObject {
    
    private let lightDumpName = "Light.dmp"
    
    func initialiseCoreData(to context: NSManagedObjectContext) {
        if let data = readFile(named: lightDumpName),
            let sync = parse(data) {
            for m in sync.modules {
                _ = Module.from(m, in: context)
            }
            try? context.save()
        }
    }
    
    private func readFile(named: String) -> Data? {
        do {
            if let path = Bundle.main.path(forResource: named, ofType: nil) {
                let url = URL(fileURLWithPath: path)
                let d = try Data(contentsOf: url)
                return d
            }
        } catch {
            print(error)
        }
        return nil
    }
    
    func download(file: String, completition: @escaping (Bool) -> () ) {
        guard let url = URL(string: AppDelegate.downloadServerURL + file) else {completition(false);return}
        let context = AppDelegate.context
        Downloader.load(url: url) { (tempPath) in
            guard let temp = tempPath else {
                completition(false)
                return
            }
            var success = true
            do {
                let data = try Data(contentsOf: temp)
                if file.matches(SharingRegex.module),
                    let module = self.parse(module: data) {
                    _ = Module.from(module, in: context)
                    do {
                        try context.save()
                    } catch {
                        print("ERROR:\nConsistencyManager.download(\(file)):\(error.localizedDescription)")
                        success = false
                    }
                } else if file.matches(SharingRegex.strong),
                    let sync = self.parse(strong: data) {
                    for str in sync {
                        _ = Strong.from(str, in: context)
                    }
                    do {
                        try context.save()
                    } catch {
                        print("ERROR:\nConsistencyManager.download(\(file)):\(error.localizedDescription)")
                        success = false
                    }
                } else if file.matches(SharingRegex.spirit),
                    let spirit = self.parse(spirit: data) {
                    _ = SpiritBook.from(spirit, in: context)
                    do {
                        try context.save()
                    } catch {
                        print("ERROR:\nConsistencyManager.download(\(file)):\(error.localizedDescription)")
                        success = false
                    }
                }
            } catch {
                print(error)
                completition(false)
            }
            completition(success)
        }
    }
    
    func remove(_ code: String, completition: @escaping () -> ()) {
        let context = AppDelegate.context
        DispatchQueue.global(qos: .userInitiated).async {
            if let key = SharingRegex.parseModule(code) {
                if let module = try? Module.get(by: key, from: context), module != nil {
                    context.delete(module!)
                    do {
                        try context.save()
                    } catch {
                        print("ERROR:\nConsistencyManager.remove(\(code)):\(error.localizedDescription)")
                    }
                }
                completition()
            } else if let type = SharingRegex.parseStrong(code) {
                Strong.remove(type, from: context)
                do {
                    try context.save()
                } catch {
                    print("ERROR:\nConsistencyManager.remove(\(code)):\(error.localizedDescription)")
                }
                completition()
            } else if let c = SharingRegex.parseSpirit(code) {
                if let b = try? SpiritBook.get(by: c, from: context), b != nil {
                    context.delete(b!)
                    do {
                        try context.save()
                    } catch {
                        print("ERROR:\nConsistencyManager.remove(\(code)):\(error.localizedDescription)")
                    }
                }
                completition()
            }
        }
    }
    
}

extension ConsistencyManager {
    private func parse(_ data: Data) -> SyncCore? {
        NSKeyedUnarchiver.setClass(SyncCore.self, forClassName: "compoundB.SyncCore")
        NSKeyedUnarchiver.setClass(SyncModule.self, forClassName: "compoundB.SyncModule")
        NSKeyedUnarchiver.setClass(SyncBook.self, forClassName: "compoundB.SyncBook")
        NSKeyedUnarchiver.setClass(SyncChapter.self, forClassName: "compoundB.SyncChapter")
        NSKeyedUnarchiver.setClass(SyncVerse.self, forClassName: "compoundB.SyncVerse")
        NSKeyedUnarchiver.setClass(SyncSpiritBook.self, forClassName: "compoundB.SyncSpiritBook")
        NSKeyedUnarchiver.setClass(SyncSpiritPage.self, forClassName: "compoundB.SyncSpiritPage")
        NSKeyedUnarchiver.setClass(SyncSpiritChapter.self, forClassName: "compoundB.SyncSpiritChapter")
        NSKeyedUnarchiver.setClass(SyncStrong.self, forClassName: "compoundB.SyncStrong")
        do {
            let core = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? SyncCore
            return core
        } catch {
            print(error)
        }
        return nil
    }
    
    private func parse(module data: Data) -> SyncModule? {
        NSKeyedUnarchiver.setClass(SyncModule.self, forClassName: "compoundB.SyncModule")
        NSKeyedUnarchiver.setClass(SyncBook.self, forClassName: "compoundB.SyncBook")
        NSKeyedUnarchiver.setClass(SyncChapter.self, forClassName: "compoundB.SyncChapter")
        NSKeyedUnarchiver.setClass(SyncVerse.self, forClassName: "compoundB.SyncVerse")
        do {
            let core = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? SyncModule
            return core
        } catch {
            print(error)
        }
        return nil
    }
    
    private func parse(strong data: Data) -> [SyncStrong]? {
        NSKeyedUnarchiver.setClass(SyncStrong.self, forClassName: "compoundB.SyncStrong")
        do {
            let core = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? [SyncStrong]
            return core
        } catch {
            print(error)
        }
        return nil
    }
    
    private func parse(spirit data: Data) -> SyncSpiritBook? {
        NSKeyedUnarchiver.setClass(SyncSpiritBook.self, forClassName: "compoundB.SyncSpiritBook")
        NSKeyedUnarchiver.setClass(SyncSpiritPage.self, forClassName: "compoundB.SyncSpiritPage")
        NSKeyedUnarchiver.setClass(SyncSpiritChapter.self, forClassName: "compoundB.SyncSpiritChapter")
        do {
            let core = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? SyncSpiritBook
            return core
        } catch {
            print(error)
        }
        return nil
    }
}

class Downloader {
    class func load(url: URL, completion: @escaping (URL?) -> ()) {
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad)
        let task = session.downloadTask(with: request) { (tempLocalUrl, _, _) in
            completion(tempLocalUrl)
        }
        task.resume()
    }
}
