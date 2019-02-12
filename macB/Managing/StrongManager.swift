//
//  StrongManager.swift
//  macB
//
//  Created by Denis Dobanda on 12.02.19.
//  Copyright © 2019 Denis Dobanda. All rights reserved.
//

import Foundation

class StrongManager: NSObject {
    class func getTooltip(from numbersString: String, type: String) -> String {
        let sp = numbersString.split(separator: "+")
        let context = AppDelegate.context
        var result = ""
        for n in sp {
            if let s = try? Strong.get(Int(String(n))!, by: type, from: context), let number = s {
                if number.original != nil {result += number.original! + "\n"}
                if number.meaning != nil {result += number.meaning! + "\n"}
            }
        }
        return result
    }
}
