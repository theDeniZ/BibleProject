//
//  Verse.swift
//  macB
//
//  Created by Denis Dobanda on 21.12.18.
//  Copyright © 2018 Denis Dobanda. All rights reserved.
//

import Cocoa
import CoreData

class Verse: NSManagedObject {
    class func create(in context: NSManagedObjectContext) -> Verse {
        return Verse(context: context)
    }
    
    class func create(from json: [String:Any], in context: NSManagedObjectContext) -> Verse? {
        guard let num = json["verse_nr"] as? Int, let t = json["verse"] as? String
            else {return nil}
        let v = Verse(context: context)
        v.number = Int32(num)
        v.text = t
        return v
    }
    
    var compound: String {
        if let t = text {
            return "\(number) \(t)"
        }
        return "\(number)"
    }
    
    var attributedCompound: NSAttributedString {
        let att = NSMutableAttributedString(string: compound)
        if let c = NSColor(named: NSColor.Name("textColor")) {
            att.addAttribute(.foregroundColor, value: c, range: NSRange(0..<att.length))
        }
        return att
    }
    
    func attributedCompound(font: NSFont, upperBaseline: [NSAttributedString.Key: Any]? = nil) -> NSAttributedString {
        let mutable = NSMutableAttributedString(attributedString: attributedCompound)
        mutable.addAttributes([.font: font], range: NSRange(0..<mutable.length))
        if let upper = upperBaseline {
            mutable.addAttributes(upper, range: NSRange(0..<"\(number)".count))
        }
        return mutable
    }
    
    func attributedCompound(size: CGFloat) -> NSAttributedString {
        var font = NSFont.systemFont(ofSize: size)
        var smallFont = NSFont.systemFont(ofSize: size * 0.6)
        if let named = AppDelegate.plistManager.getFont() {
            font = NSFont(name: named + "MT", size: size)!
            smallFont = NSFont(name: named + "MT", size: size * 0.6)!
        }
        let upperAttribute: [NSAttributedString.Key: Any] =
            [NSAttributedString.Key.baselineOffset : size * 0.3,
             NSAttributedString.Key.font : smallFont]
        return attributedCompound(font: font, upperBaseline: upperAttribute)
    }
}
