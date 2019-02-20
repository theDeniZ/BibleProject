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
    private let lightDumpName = "Light.dmp"
    private let fullDumpName = "Full.dmp"
    
    private let context: NSManagedObjectContext = AppDelegate.context
    
    var isConsistent: Bool {
        return true
    }
    
    func initialiseCoreData() {
        if let data = readFile(named: lightDumpName),
            let sync = parse(data) {
            write(sync)
        }
    }
    
    private func write(_ coreSync: SyncCore) {
        for m in coreSync.modules {
            _ = Module.from(m, in: context)
        }
        try? context.save()
        
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
        do {
            let core = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? SyncCore
            return core
        } catch {
            print(error)
        }
        return nil
    }
}
