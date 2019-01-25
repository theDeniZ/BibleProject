//
//  Global.swift
//  macB
//
//  Created by Denis Dobanda on 13.01.19.
//  Copyright © 2019 Denis Dobanda. All rights reserved.
//

import Foundation

struct SyncStrong {
    var number: Int
    var meaning: String?
    var original: String?
}

enum BonjourClientState {
    case newborn
    case alive
    case wise
    case ready
    case busy
    case deprecated
    case finished
    case waiting
    case dead
}

enum BonjourClientGreetingOption: String {
    case firstMeet = "hi, ready to get to know me?"
    case confirm = "yes"
    case ready = "ready to receive"
    case done = "ok, next"
    case finished = "are you ok?"
    case bye = "bye"
    //    case
}

struct SharingRegex {
    static var module = "Module\\((.*)\\)"
    static var strong = "Strong\\((.*)\\)"
    static var spirit = "Spirit\\((.*)\\)"
    
    static func module(_ name: String) -> String {
        return "Module(" + name + ")"
    }
    static func strong(_ name: String) -> String {
        return "Strong(" + name + ")"
    }
    static func spirit(_ name: String) -> String {
        return "Spirit(" + name + ")"
    }
    static func sync(_ name: String, counting: Int) -> String {
        return "Sync(\(name)):\(counting)"
    }
}
