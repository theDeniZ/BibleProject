//
//  Global.swift
//  macB
//
//  Created by Denis Dobanda on 13.01.19.
//  Copyright © 2019 Denis Dobanda. All rights reserved.
//

import Foundation
import CoreData

struct StrongId {
    static let oldTestament = "Hebrew"
    static let newTestament = "Greek"
    static let plistIdentifier = "strong_keys"
}

enum StrongNumbers: String, CaseIterable {
    case oldTestament = "Hebrew"
    case newTestament = "Greek"
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
        return "Sync(\(name)):\(counting)+0"
    }
    static func sync(_ name: String, counting: Int, last: Int) -> String {
        return "Sync(\(name)):\(counting)+\(last)"
    }
    
    static func parseModule(_ str: String) -> String? {
        if str.matches(SharingRegex.module) {
            return str.capturedGroups(withRegex: SharingRegex.module)![0]
        }
        return nil
    }
    static func parseStrong(_ str: String) -> String? {
        if str.matches(SharingRegex.strong) {
            return str.capturedGroups(withRegex: SharingRegex.strong)![0]
        }
        return nil
    }
    static func parseSpirit(_ str: String) -> String? {
        if str.matches(SharingRegex.spirit) {
            return str.capturedGroups(withRegex: SharingRegex.spirit)![0]
        }
        return nil
    }
}

/// A Core Data model Strong representation for Coding/Decoding
///
/// Contains: number: Int, meaning: String?, original: String?, type: String?
class SyncStrong: NSObject, NSSecureCoding {
    var number: Int
    var meaning: String?
    var original: String?
    var type: String
    
    /// Initialise SyncStrong object with a given parameters
    ///
    /// - Parameters:
    ///   - number: Strong number
    ///   - meaning: Strong meaning
    ///   - original: Strong original
    ///   - type: Strong type
    init(number: Int, meaning: String?, original: String?, type: String) {
        self.number = number
        self.meaning = meaning
        self.original = original
        self.type = type
    }
    
    /// Initialise SyncStrong object from a Strong instance
    ///
    /// - Parameter strong: a Strong instance
    init(strong: Strong) {
        self.number = Int(strong.number)
        self.meaning = strong.meaning
        self.original = strong.original
        self.type = strong.type!
    }
    
    required init?(coder aDecoder: NSCoder) {
        number = aDecoder.decodeInteger(forKey: "number")
        meaning = aDecoder.decodeObject(forKey: "meaning") as? String
        original = aDecoder.decodeObject(forKey: "original") as? String
        type = aDecoder.decodeObject(forKey: "type") as? String ?? StrongId.oldTestament
    }
    
    static var supportsSecureCoding: Bool {
        return true
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(number, forKey: "number")
        aCoder.encode(meaning, forKey: "meaning")
        aCoder.encode(original, forKey: "original")
        aCoder.encode(type, forKey: "type")
    }
}

/// A Core Data model Module representation for Coding/Decoding
///
/// Contains: key: String, local: Bool, name: String?, books: [SyncBook]
class SyncModule: NSObject, NSSecureCoding {
    var key: String
    var name: String?
    var books: [SyncBook] = []
    
    /// Initialise SyncModule object with a key, a name and (optinally) a local Bool value.
    /// Needs a separate .books initialisation
    ///
    /// - Parameters:
    ///   - key: Module key
    ///   - name: Module name
    ///   - local: local Bool flag. Default: true
    init(key: String, name: String?, local: Bool = true) {
        self.key = key
        self.name = name
    }
    
    /// Initialise SyncModule object from a Module instance
    ///
    /// - Parameter module: a Module instance
    init(module: Module) {
        self.key = module.key!
        self.name = module.name
        if let b = module.books?.array as? [Book] {
            for book in b {
                books.append(SyncBook(book: book))
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        key = aDecoder.decodeObject(forKey: "key") as! String
        name = aDecoder.decodeObject(forKey: "name") as? String
        books = aDecoder.decodeObject(forKey: "books") as? [SyncBook] ?? []
    }
    
    static var supportsSecureCoding: Bool {
        return true
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(key, forKey: "key")
        aCoder.encode(name, forKey: "name")
        aCoder.encode(books, forKey: "books")
    }
}

/// A Core Data model Book representation for Coding/Decoding
///
/// Contains: number: Int, name: String?, chapters: [SyncChapter]
class SyncBook: NSObject, NSSecureCoding {
    var number: Int
    var name: String?
    var chapters: [SyncChapter] = []
    
    /// Initialise SyncBook object with a number and a name.
    /// Needs a separate .chapters initialisation
    ///
    /// - Parameters:
    ///   - number: Book number
    ///   - name: Book name
    init(number: Int, name: String?) {
        self.number = number
        self.name = name
    }
    
    /// Initialise SyncBook object from existing Book instance
    ///
    /// - Parameter book: a Book instance
    init(book: Book) {
        self.number = Int(book.number)
        self.name = book.name
        if let c = book.chapters?.array as? [Chapter] {
            for chapter in c {
                chapters.append(SyncChapter(chapter: chapter))
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        number = aDecoder.decodeInteger(forKey: "number")
        name = aDecoder.decodeObject(forKey: "name") as? String
        chapters = aDecoder.decodeObject(forKey: "chapters") as? [SyncChapter] ?? []
    }
    
    static var supportsSecureCoding: Bool {
        return true
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(number, forKey: "number")
        aCoder.encode(name, forKey: "name")
        aCoder.encode(chapters, forKey: "chapters")
    }
}

/// A Core Data model Chapter representation for Coding/Decoding
///
/// Contains: number: Int, verses: [SyncVerse]
class SyncChapter: NSObject, NSSecureCoding {
    var number: Int
    var verses: [SyncVerse] = []
    
    /// Initialise SyncChapter object with a given number.
    /// Also needs a separate .verses initialisatoin
    ///
    /// - Parameter number: a Chapter number
    init(number: Int) {
        self.number = number
    }
    
    /// Initialise SyncChapter object from existing Chapter instance
    ///
    /// - Parameter chapter: a Chapter instance
    init(chapter: Chapter) {
        self.number = Int(chapter.number)
        if let v = chapter.verses?.array as? [Verse] {
            for verse in v {
                verses.append(SyncVerse(verse: verse))
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        number = aDecoder.decodeInteger(forKey: "number")
        verses = aDecoder.decodeObject(forKey: "verses") as? [SyncVerse] ?? []
    }
    
    static var supportsSecureCoding: Bool {
        return true
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(number, forKey: "number")
        aCoder.encode(verses, forKey: "verses")
    }
}

/// A Core Data model Verse representation for Coding/Decoding
///
/// Contains: number: Int, text: String
class SyncVerse: NSObject, NSSecureCoding {
    var number: Int
    var text: String
    
    /// Initialise a SyncVerse object. No other actions required
    ///
    /// - Parameters:
    ///   - number: a Verse number
    ///   - text: a Verse text
    init(number: Int, text: String) {
        self.number = number
        self.text = text
    }
    
    /// Initialise s SyncVerse object from existing Verse instance
    ///
    /// - Parameter verse: a Verse instance
    init(verse: Verse) {
        self.number = Int(verse.number)
        self.text = verse.text ?? ""
    }
    
    required init?(coder aDecoder: NSCoder) {
        number = aDecoder.decodeInteger(forKey: "number")
        text = aDecoder.decodeObject(forKey: "text") as! String
    }
    
    static var supportsSecureCoding: Bool {
        return true
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(number, forKey: "number")
        aCoder.encode(text, forKey: "text")
    }
}

/// A Core Data model SpiritBook representation for Coding/Decoding
class SyncSpiritBook: NSObject, NSSecureCoding {
    var index: Int
    var author: String?
    var code: String
    var name: String
    var lang: String?
    var chapters: [SyncSpiritChapter] = []
    
    /// Initialise a SyncSpiritBook with a number, a code and a name
    /// Also needs to be set .chapters property
    ///
    /// - Parameters:
    ///   - index: a SpiritBook index
    ///   - code: a SpiritBook code
    ///   - name: a SpiritBook name
    init(index: Int, code: String, name: String) {
        self.index = index
        self.code = code
        self.name = name
    }
    
    /// Initialise a SyncSpiritBook object from a given SpiritBook instance
    ///
    /// - Parameter spirit: a SpiritBook instance
    init(spirit: SpiritBook) {
        index = Int(spirit.index)
        author = spirit.author
        code = spirit.code ?? ""
        name = spirit.name ?? ""
        lang = spirit.lang
        if let c = spirit.chapters?.array as? [SpiritChapter] {
            for chapter in c {
                chapters.append(SyncSpiritChapter(spirit: chapter))
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        index = aDecoder.decodeInteger(forKey: "index")
        author = aDecoder.decodeObject(forKey: "author") as? String
        code = aDecoder.decodeObject(forKey: "code") as! String
        name = aDecoder.decodeObject(forKey: "name") as! String
        lang = aDecoder.decodeObject(forKey: "lang") as? String
        chapters = aDecoder.decodeObject(forKey: "chapters") as? [SyncSpiritChapter] ?? []
    }
    
    static var supportsSecureCoding: Bool {
        return true
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(index, forKey: "index")
        aCoder.encode(author, forKey: "author")
        aCoder.encode(code, forKey: "code")
        aCoder.encode(name, forKey: "name")
        aCoder.encode(lang, forKey: "lang")
        aCoder.encode(chapters, forKey: "chapters")
    }
}

/// A Core Data model SpiritChapter representation for Coding/Decoding
class SyncSpiritChapter: NSObject, NSSecureCoding {
    var number: Int
    var index: Int
    var intro: String?
    var title: String?
    var pages: [SyncSpiritPage] = []
    
    /// Initialise SyncSpiritChapter with a given number and a index in hierarchy (unique)
    /// Also needs initialisation of .pages
    ///
    /// - Parameters:
    ///   - number: a Chapter number
    ///   - index: index in hierarchy for ordering
    init(number: Int, index: Int) {
        self.number = number
        self.index = index
    }
    
    /// Initialise SyncSpiritChapter with a given SpiritChapter instance
    ///
    /// - Parameter spirit: a SpiritChapter instance
    init(spirit: SpiritChapter) {
        number = Int(spirit.number)
        index = Int(spirit.index)
        intro = spirit.intro
        title = spirit.title
        if let p = spirit.pages?.array as? [Page] {
            for page in p {
                pages.append(SyncSpiritPage(spirit: page))
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        number = aDecoder.decodeInteger(forKey: "number")
        index = aDecoder.decodeInteger(forKey: "index")
        intro = aDecoder.decodeObject(forKey: "intro") as? String
        title = aDecoder.decodeObject(forKey: "title") as? String
        pages = aDecoder.decodeObject(forKey: "pages") as? [SyncSpiritPage] ?? []
    }
    
    static var supportsSecureCoding: Bool {
        return true
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(number, forKey: "number")
        aCoder.encode(index, forKey: "index")
        aCoder.encode(intro, forKey: "intro")
        aCoder.encode(title, forKey: "title")
        aCoder.encode(pages, forKey: "pages")
    }
}

/// A Core Data model Page representation for Coding/Decoding
class SyncSpiritPage: NSObject, NSSecureCoding {
    var number: Int
    var roman: Bool
    var text: String
    
    /// Initialise SyncSpiritPage with a given number, roman flag and a text.
    ///
    /// - Parameters:
    ///   - number: a Page number
    ///   - roman: indication to present number as a roman literal
    ///   - text: a Page text
    init(number: Int, roman: Bool, text: String) {
        self.number = number
        self.roman = roman
        self.text = text
    }
    
    /// Initialise SyncSpiritPage object from a Page instance
    ///
    /// - Parameter spirit: a Page instance
    init(spirit: Page) {
        self.number = Int(spirit.number)
        self.roman = spirit.roman
        self.text = spirit.text ?? ""
    }
    
    required init?(coder aDecoder: NSCoder) {
        number = aDecoder.decodeInteger(forKey: "number")
        roman = aDecoder.decodeBool(forKey: "roman")
        text = aDecoder.decodeObject(forKey: "text") as! String
    }
    
    static var supportsSecureCoding: Bool {
        return true
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(number, forKey: "number")
        aCoder.encode(roman, forKey: "roman")
        aCoder.encode(text, forKey: "text")
    }
}

/// A whole Core Data model representation for Coding/Decoding
class SyncCore: NSObject, NSSecureCoding {
    var modules: [SyncModule] = []
    var strongs: [SyncStrong] = []
    var spirit: [SyncSpiritBook] = []
    
    override init() {
        super.init()
    }
    
    init(in context: NSManagedObjectContext) {
        if let m = try? Module.getAll(from: context) {
            for module in m {
                modules.append(SyncModule(module: module))
            }
        }
        if let strs = try? Strong.getAll(context) {
            for s in strs {
                strongs.append(SyncStrong(strong: s))
            }
        }
        if let sp = try? SpiritBook.getAll(from: context) {
            for s in sp {
                spirit.append(SyncSpiritBook(spirit: s))
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        modules = aDecoder.decodeObject(forKey: "modules") as? [SyncModule] ?? []
        strongs = aDecoder.decodeObject(forKey: "strongs") as? [SyncStrong] ?? []
        spirit = aDecoder.decodeObject(forKey: "spirit") as? [SyncSpiritBook] ?? []
    }
    
    static var supportsSecureCoding: Bool {return true}
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(modules, forKey: "modules")
        aCoder.encode(strongs, forKey: "strongs")
        aCoder.encode(spirit, forKey: "spirit")
    }
    
}


class SearchResult: NSObject {
    var title: String
    var text: String
    var index: (Int, Int, Int)
    
    override init() {
        title = ""
        text = ""
        index = (0,0,0)
        super.init()
    }
    init(title: String) {
        self.title = title
        text = ""
        index = (0,0,0)
        super.init()
    }
    init(title: String, text: String) {
        self.title = title
        self.text = text
        index = (0,0,0)
        super.init()
    }
    init(title: String, text: String, index: (Int,Int,Int)) {
        self.title = title
        self.text = text
        self.index = index
        super.init()
    }
}

class DownloadModel: NSObject {
    var size: String
    var name: String
    var loaded: Bool
    var loading: Bool
    var path: String
    
    init(size: String, name: String, loaded: Bool, loading: Bool, path: String) {
        self.size = size
        self.name = name
        self.loaded = loaded
        self.loading = loading
        self.path = path
    }
}

class Presentable: NSObject {
    var index: Int
    var attributedString: NSAttributedString
    
    init(_ attributedString: NSAttributedString, index: Int) {
        self.index = index
        self.attributedString = attributedString
    }
}
