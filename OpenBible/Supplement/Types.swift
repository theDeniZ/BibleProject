import Foundation

enum BonjourServerState {
    case greeting
    case teaching
    case waiting
    case inSync
}

enum BonjourClientGreetingOption: String {
    case firstMeet = "hi, ready to get to know me?"
    case confirm = "yes"
    case ready = "ready to receive"
    case done = "ok, next"
    case finished = "are you ok?"
    case bye = "bye"
    case regexForSync = "Sync\\((.+)\\):(\\d+)\\+(\\d+)"
}

enum SyncingState {
    case none
    case strongs(String)
    case module(String)
    case spirit
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
}

class SyncStrong: NSObject, NSSecureCoding {
    var number: Int
    var meaning: String?
    var original: String?
    
    init(number: Int, meaning: String?, original: String?) {
        self.number = number
        self.meaning = meaning
        self.original = original
    }
    
    static var supportsSecureCoding: Bool {
        return true
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(number, forKey: "number")
        aCoder.encode(meaning, forKey: "meaning")
        aCoder.encode(original, forKey: "original")
    }
    
    required init?(coder aDecoder: NSCoder) {
        number = aDecoder.decodeInteger(forKey: "number")
        meaning = aDecoder.decodeObject(forKey: "meaning") as? String
        original = aDecoder.decodeObject(forKey: "original") as? String
    }
}

class SyncModule: NSObject, NSSecureCoding {
    var key: String
    var local: Bool
    var name: String?
    var books: [SyncBook] = []
    
    init(key: String, name: String?, local: Bool = true) {
        self.key = key
        self.name = name
        self.local = local
    }
    
    static var supportsSecureCoding: Bool {
        return true
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(key, forKey: "key")
        aCoder.encode(local, forKey: "local")
        aCoder.encode(name, forKey: "name")
        aCoder.encode(books, forKey: "books")
    }
    
    required init?(coder aDecoder: NSCoder) {
        key = aDecoder.decodeObject(forKey: "key") as! String
        local = aDecoder.decodeObject(forKey: "meaning") as? Bool ?? false
        name = aDecoder.decodeObject(forKey: "name") as? String
        books = aDecoder.decodeObject(forKey: "books") as? [SyncBook] ?? []
    }
}

class SyncBook: NSObject, NSSecureCoding {
    var number: Int
    var name: String?
    var chapters: [SyncChapter] = []
    
    init(number: Int, name: String?) {
        self.number = number
        self.name = name
    }
    
    static var supportsSecureCoding: Bool {
        return true
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(number, forKey: "number")
        aCoder.encode(name, forKey: "name")
        aCoder.encode(chapters, forKey: "chapters")
    }
    
    required init?(coder aDecoder: NSCoder) {
        number = aDecoder.decodeInteger(forKey: "number")
        name = aDecoder.decodeObject(forKey: "name") as? String
        chapters = aDecoder.decodeObject(forKey: "chapters") as? [SyncChapter] ?? []
    }
}

class SyncChapter: NSObject, NSSecureCoding {
    var number: Int
    var verses: [SyncVerse] = []
    
    init(number: Int) {
        self.number = number
    }
    
    static var supportsSecureCoding: Bool {
        return true
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(number, forKey: "number")
        aCoder.encode(verses, forKey: "verses")
    }
    
    required init?(coder aDecoder: NSCoder) {
        number = aDecoder.decodeInteger(forKey: "number")
        verses = aDecoder.decodeObject(forKey: "verses") as? [SyncVerse] ?? []
    }
}

class SyncVerse: NSObject, NSSecureCoding {
    var number: Int
    var text: String
    
    init(number: Int, text: String) {
        self.number = number
        self.text = text
    }
    
    static var supportsSecureCoding: Bool {
        return true
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(number, forKey: "number")
        aCoder.encode(text, forKey: "text")
    }
    
    required init?(coder aDecoder: NSCoder) {
        number = aDecoder.decodeInteger(forKey: "number")
        text = aDecoder.decodeObject(forKey: "text") as! String
    }
}
