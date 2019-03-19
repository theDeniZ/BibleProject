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
            return "\(number) \(t[...t.index(t.endIndex, offsetBy: -2)])"
        }
        return "\(number)"
    }
    
    var reference: String {
        var res = ""
        if chapter != nil,
            chapter!.book != nil {
            res += chapter!.book!.name ?? ""
            res += " \(chapter!.number):"
            res += "\(number)"
        }
        return res
    }
    
    var attributedCompound: NSAttributedString {
        let att = NSMutableAttributedString(string: compound)
        if let c = NSColor(named: NSColor.Name("textColor")) {
            att.addAttribute(.foregroundColor, value: c, range: NSRange(0..<att.length))
        }
        if let colorData = color,
            let color = NSKeyedUnarchiver.unarchiveObject(with: colorData) as? NSColor {
            att.addAttribute(.backgroundColor, value: color, range: NSRange(0..<att.length))
            att.addAttribute(.foregroundColor, value: NSColor.black, range: NSRange(0..<att.length))
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
            font = NSFont(name: named, size: size)!
            smallFont = NSFont(name: named, size: size * 0.6)!
        }
        let upperAttribute: [NSAttributedString.Key: Any] =
            [NSAttributedString.Key.baselineOffset : size * 0.3,
             NSAttributedString.Key.font : smallFont]
        return attributedCompound(font: font, upperBaseline: upperAttribute)
    }
    
    
    class func from(_ sync: SyncVerse, in context: NSManagedObjectContext) -> Verse {
        let new = Verse(context: context)
        new.number = Int32(sync.number)
        new.text = sync.text
        return new
    }
    
    class func find(containing text: String, moduling: [Module], in context: NSManagedObjectContext) throws -> [Verse] {
        guard moduling.count > 0 else {return []}
        var moduleReg = "chapter.book.module = %@"
        var array: [Any] = [".*(" + text + ").*", moduling[0]]
        for i in 1..<moduling.count {
            moduleReg += " OR chapter.book.module = %@"
            array.append(moduling[i])
        }
        
        let request: NSFetchRequest<Verse> = Verse.fetchRequest()
        request.predicate = NSPredicate(
            format: "text MATCHES %@ AND (" + moduleReg + ")",
            argumentArray: array
        )
        let bookSD = NSSortDescriptor(key: "chapter.book.number", ascending: true)
        let chapterSD = NSSortDescriptor(key: "chapter.number", ascending: true)
        let verseSD = NSSortDescriptor(key: "number", ascending: true)
        request.sortDescriptors = [bookSD, chapterSD, verseSD]
        
        return try context.fetch(request)
    }
}
