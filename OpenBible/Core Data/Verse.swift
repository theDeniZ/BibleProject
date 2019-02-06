//
//  Verse.swift
//  SplitB
//
//  Created by Denis Dobanda on 25.10.18.
//  Copyright © 2018 Denis Dobanda. All rights reserved.
//

import UIKit
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
            return " \(number) \(t)"
        }
        return " \(number)"
    }
    
    var attributedCompound: NSAttributedString {
        let att = NSMutableAttributedString(string: compound)
        return att
    }
    
    func attributedCompound(font: UIFont, upperBaseline: [NSAttributedString.Key: Any]? = nil) -> NSAttributedString {
        let mutable = NSMutableAttributedString(attributedString: attributedCompound)
        mutable.addAttributes([.font: font], range: NSRange(0..<mutable.length))
        mutable.addAttributes([.baselineOffset : 0], range: NSRange(0..<mutable.length))
        if let upper = upperBaseline {
            mutable.addAttributes(upper, range: NSRange(1..<"\(number)".count + 1))
        }
        return mutable
    }
    
    func attributedCompound(size: CGFloat) -> NSAttributedString {
        let font = UIFont.systemFont(ofSize: size)
        let upperAttribute: [NSAttributedString.Key: Any] =
            [NSAttributedString.Key.baselineOffset : size * 0.333,
             NSAttributedString.Key.font : UIFont.italicSystemFont(ofSize: size * 0.666),
             .foregroundColor : UIColor.gray.withAlphaComponent(0.7)]
        return attributedCompound(font: font, upperBaseline: upperAttribute)
    }
}
