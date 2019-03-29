//
//  SettingsService.swift
//  OpenBible
//
//  Created by Denis Dobanda on 25.03.19.
//  Copyright © 2019 Denis Dobanda. All rights reserved.
//

import Foundation

class SettingService: NSObject {
    
    var isStrongsOn: Bool {
        get {
            return plist.isStrongsOn
        }
        set {
            plist.isStrongsOn = newValue
        }
    }
    
    var numberOfModules: Int {
        get {
            return plist.portraitNumber
        }
        set {
            plist.portraitNumber = newValue
        }
    }
    
    private var plist: PlistManager = AppDelegate.plistManager
}
