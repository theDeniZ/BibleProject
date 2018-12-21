//
//  Module.swift
//  SplitB
//
//  Created by Denis Dobanda on 24.10.18.
//  Copyright © 2018 Denis Dobanda. All rights reserved.
//

import Foundation

class ModuleOffline {
    var key, name: String
    
    init() {
        name = ""
        key = ""
    }
    
    init(_ n: String) {
        name = n
        key = n
    }
    
    init(_ n: String, _ k: String) {
        name = n
        key = k
    }
}
