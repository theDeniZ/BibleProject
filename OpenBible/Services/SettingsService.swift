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
            return PlistManager.shared.isStrongsOn
        }
        set {
            PlistManager.shared.isStrongsOn = newValue
        }
    }
    
    var numberOfModules: Int {
        get {
            return PlistManager.shared.portraitNumber
        }
        set {
            PlistManager.shared.portraitNumber = newValue
        }
    }
}
