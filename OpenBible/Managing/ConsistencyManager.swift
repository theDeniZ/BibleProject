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
    var delegate: ConsistencyManagerDelegate?
    
    private let lightDumpName = "Light.dmp"
    private let fullDumpName = "Full.dmp"
    private let consistentDumpName = "Consistent.dmp"
    
    private var timer: Timer?
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func initialiseCoreData() {
        if let data = readFile(named: lightDumpName),
            let sync = parse(data) {
            write(sync)
            delegate?.consistentManagerDidChangedModel()
        }
    }
    
    func startConsistencyCheck() {
        let context = AppDelegate.context
        DispatchQueue.global(qos: .background).async {
            var inconsistent = [String]()
            if let data = self.readFile(named: self.consistentDumpName),
                let dict = self.parseConsistency(data) {
                for (key, value) in dict {
                    if Module.checkConsistency(of: key, in: context) != value {
                        inconsistent.append(key)
                    }
                }
                if inconsistent.count > 0 {
                    self.makeConsistent(inconsistent, context: context)
                    self.delegate?.consistentManagerDidChangedModel()
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
    
    private func makeConsistent(_ array: [String], context: NSManagedObjectContext) {
        if let data = readFile(named: fullDumpName),
            let sync = parse(data) {
            for module in sync.modules {
                if array.contains(module.key) {
                    _ = Module.from(module, in: context)
                    try? context.save()
                }
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
}
