//
//  ConsistencyManager.swift
//  OpenBible
//
//  Created by Denis Dobanda on 20.02.19.
//  Copyright © 2019 Denis Dobanda. All rights reserved.
//

import Foundation
import CoreData

class ConsistencyManager: NSObject {
    var context: NSManagedObjectContext
    var delegates: [ConsistencyManagerDelegate]?
    
    private let lightDumpName = "Light.dmp"
    private let fullDumpName = "Full.dmp"
    private let consistentDumpName = "Consistent.dmp"
    
    private var overallCountOfEntitiesToLoad = 0
    private var processedEntities = 0
    private var timer: Timer?
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func initialiseCoreData() {
        if let data = readFile(named: lightDumpName),
            let sync = parse(data) {
            write(sync)
            self.broadcastChange()
        }
    }
    
    func startConsistencyCheck() {
        let context = AppDelegate.context
        DispatchQueue.global(qos: .userInteractive).async {
            self.overallCountOfEntitiesToLoad = 0
            self.processedEntities = 0
            var inconsistentModules = [String]()
            var inconsistentStrongs = [String]()
            var inconsistentBooks = [String]()
            if let data = self.readFile(named: self.consistentDumpName),
                let dict = self.parseConsistency(data) {
                for (key, value) in dict {
                    if let module = SharingRegex.parseModule(key),
                        Module.checkConsistency(of: module, in: context) != value {
                        inconsistentModules.append(module)
                        self.overallCountOfEntitiesToLoad += value
                    } else if let strong = SharingRegex.parseStrong(key),
                        Strong.count(of: strong, in: context) != value {
                        inconsistentStrongs.append(strong)
                        self.overallCountOfEntitiesToLoad += value
                    } else if let book = SharingRegex.parseSpirit(key),
                        SpiritBook.checkConsistency(of: book, in: context) != value {
                        inconsistentBooks.append(book)
//                        self.overallCountOfEntitiesToLoad += value
                    }
                }
                if let syncData = self.readFile(named: self.fullDumpName),
                    let sync = self.parse(syncData) {
                    self.makeConsistent(modules: inconsistentModules, context: context, sync: sync)
                    self.makeConsistent(strongs: inconsistentStrongs, context: context, sync: sync)
//                    self.makeConsistent(books: inconsistentBooks, context: context, sync: sync)
                    self.broadcastChange()
                }
            }
            print("Consistency check is done")
        }
    }
    
    private func write(_ coreSync: SyncCore) {
        for m in coreSync.modules {
            _ = Module.from(m, in: context)
        }
        try? context.save()
    }
    
    private func makeConsistent(modules array: [String], context: NSManagedObjectContext, sync: SyncCore) {
        guard array.count > 0 else {return}
        for module in sync.modules {
            if array.contains(module.key) {
                let m = Module.from(module, in: context)
                processedEntities += Module.checkConsistency(of: m, in: context)
                broadCastProgress()
                try? context.save()
            }
        }
    }
    
    private func makeConsistent(strongs array: [String], context: NSManagedObjectContext, sync: SyncCore) {
        guard array.count > 0 else {return}
        if array.count == 1 {
            for strong in array {
                sync.strongs.filter({$0.type == strong}).forEach {_ = Strong.from($0, in: context);processedEntities += 1;broadCastProgress()}
            }
        } else { // array count == 2, which means, all of them
            Strong.remove(array[0], from: context)
            Strong.remove(array[1], from: context)
            for s in sync.strongs {
                let strong = Strong(context: context)
                strong.meaning = s.meaning
                strong.number = Int32(s.number)
                strong.original = s.original
                strong.type = s.type
                processedEntities += 1
                broadCastProgress()
            }
        }
        do {
            try context.save()
        } catch {print(error)}
    }
    
    private func makeConsistent(books array: [String], context: NSManagedObjectContext, sync: SyncCore) {
        guard array.count > 0 else {return}
        for book in sync.spirit {
            if array.contains(book.code) {
                let b = SpiritBook.from(book, in: context)
                processedEntities += SpiritBook.checkConsistency(of: b, in: context)
                broadCastProgress()
                try? context.save()
            }
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
    
    private func parse(_ data: Data) -> SyncCore? {
        NSKeyedUnarchiver.setClass(SyncCore.self, forClassName: "macB.SyncCore")
        NSKeyedUnarchiver.setClass(SyncModule.self, forClassName: "macB.SyncModule")
        NSKeyedUnarchiver.setClass(SyncBook.self, forClassName: "macB.SyncBook")
        NSKeyedUnarchiver.setClass(SyncChapter.self, forClassName: "macB.SyncChapter")
        NSKeyedUnarchiver.setClass(SyncVerse.self, forClassName: "macB.SyncVerse")
        NSKeyedUnarchiver.setClass(SyncSpiritBook.self, forClassName: "macB.SyncSpiritBook")
        NSKeyedUnarchiver.setClass(SyncSpiritPage.self, forClassName: "macB.SyncSpiritPage")
        NSKeyedUnarchiver.setClass(SyncSpiritChapter.self, forClassName: "macB.SyncSpiritChapter")
        NSKeyedUnarchiver.setClass(SyncStrong.self, forClassName: "macB.SyncStrong")
        do {
            let core = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? SyncCore
            return core
        } catch {
            print(error)
        }
        return nil
    }
    
    private func parseConsistency(_ data: Data) -> [String:Int]? {
        do {
            let d = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? [String:Int]
            return d
        } catch {
            print(error)
        }
        return nil
    }
    
    private func broadCastProgress() {
        delegates?.forEach {$0.condidtentManagerDidUpdatedProgress?(to: Double(processedEntities) / Double(overallCountOfEntitiesToLoad))}
    }
    
    private func broadcastChange() {
        delegates?.forEach {$0.consistentManagerDidChangedModel?()}
    }
}

extension ConsistencyManager {
    func addDelegate(_ del: ConsistencyManagerDelegate) {
        switch delegates {
        case .none:
            delegates = [del]
        case .some(_):
            delegates!.append(del)
        }
    }
    
    func removeDelegate(_ del: ConsistencyManagerDelegate) {
        switch delegates {
        case .some(var some):
            some.removeAll {$0.hashValue == del.hashValue}
        default: break
        }
    }
}
