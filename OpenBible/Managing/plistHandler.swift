//
//  plistHandler.swift
//  CurseWork
//
//  Created by Denis Dobynda on 04.02.18.
//  Copyright © 2018 Denis Dobynda. All rights reserved.
//

import UIKit

class PlistHandler {
    
    // MARK: Public API
    var plistPath: String?
    
    func setValue(_ value: Any?, of key: String) {
        if let path = plistPath, let dict = NSMutableDictionary(contentsOfFile: path) {
            dict.setValue(value, forKey: key)
            if (!dict.write(toFile: path, atomically: true)) {
                print("PlistHandler:setValue(\(String(describing: value)), of: \(key) - failing")
                if (!dict.write(toFile: path, atomically: false)) {
                    print("PlistHandler:setValue(\(String(describing: value)), of: \(key) - failed")
                }
            }
        }
    }
    
    func get<T> (to variable: inout T, of key: String) {
        if let path = plistPath, let dict = NSDictionary(contentsOfFile: path), let opt = dict[key] {
            if let _ = variable as? String, let str = opt as? String {
                variable = str as! T
            } else if let _ = variable as? Int, let num = opt as? Int {
                variable = num as! T
            } else if let _ = variable as? Bool, let boo = opt as? Bool {
                variable = boo as! T
            } else if let _ = variable as? CGFloat, let str = opt as? String, let value = Double(str) {
                variable = CGFloat(value) as! T
            } else if let _ = variable as? Double, let str = opt as? String, let value = Double(str) {
                variable = value as! T
            } else if let _ = variable as? [String:CGFloat], let value = opt as? [String:AnyObject] {
                var color = [String:CGFloat]()
                if let string = value["red"] as? String, let double = Double(string) {
                    color["red"] = CGFloat(double)
                }
                if let string = value["green"] as? String, let double = Double(string) {
                    color["green"] = CGFloat(double)
                }
                if let string = value["blue"] as? String, let double = Double(string) {
                    color["blue"] = CGFloat(double)
                }
                if let string = value["alpha"] as? String, let double = Double(string) {
                    color["alpha"] = CGFloat(double)
                }
                variable = color as! T
            }
        }
    }
    
    // MARK: initializations
    init() {
        plistPath = nil
    }
    
    init(_ path: String?) {
        plistPath = path
    }
}
