import Foundation

struct ListRoot {
    var typeName: String = ""
    var container: [ListObject] = []
}

struct ListObject {
    var title: String = ""
    var nested: [ListObject] = []
    var index: SpiritIndex?
    var moduleKey: String?
    var numberInOrder: Int?
    
    init(_ title: String) {
        self.title = title
    }
    
    init(_ title: String, nested: [ListObject]) {
        self.title = title
        self.nested = nested
    }
    
    init(_ title: String, nested: [ListObject], index: SpiritIndex) {
        self.init(title, nested: nested)
        self.index = index
    }
}

enum ListType {
    case bible
    case strong
    case spirit
}

class ListManager: NSObject {
    
    var context = AppDelegate.context
    var typesToDisplay: [ListType]?
    
    
    func getListOfAll() -> [ListRoot] {
        var allOfThem = [ListRoot]()
        
        if let selected = typesToDisplay {
            if selected.contains(.bible) {
                allOfThem.append(getBibles())
            }
            if selected.contains(.strong) {
                allOfThem.append(getStrongs())
            }
            if selected.contains(.spirit) {
                allOfThem.append(getSpirit())
            }
        } else {
            allOfThem.append(getBibles())
            allOfThem.append(getStrongs())
            allOfThem.append(getSpirit())
        }
        return allOfThem
    }
    
    private func getBibles() -> ListRoot {
        var bibles = ListRoot(typeName: "Bible", container: [])
        if let modules = try? Module.getAll(from: context) {
            for module in modules {
                let name = module.name ?? module.key ?? "Error: unidentified module"
                var bible = ListObject(name)
                if let books = module.books?.array as? [Book] {
                    let sorted = books.sorted {$0.number < $1.number}
                    for i in 0..<sorted.count {
                        let book = sorted[i]
                        let bookName = book.name ?? "Book \(book.number)"
                        var listBook = ListObject(bookName)
                        let count = book.chapters?.array.count ?? 0
                        var number = ListObject("\(count) Chapter\(count > 1 ? "s" : "")")
                        number.numberInOrder = i
                        number.moduleKey = module.key
                        listBook.nested = [number]
                        bible.nested.append(listBook)
                    }
                }
                bibles.container.append(bible)
            }
        }
        return bibles
    }
    
    private func getStrongs() -> ListRoot {
        var strongs = ListRoot(typeName: "Strong's Numbers", container: [])
        for str in StrongNumbers.allCases {
            let count = Strong.count(of: str.rawValue, in: context)
            if count > 0 {
                let s = ListObject(str.rawValue, nested: [ListObject("\(count)")])
                strongs.container.append(s)
            }
        }
        return strongs
    }
    
    private func getSpirit() -> ListRoot {
        var spirit = ListRoot(typeName: "Spirit of Prophecy", container: [])
        if let sp = try? SpiritBook.getAll(from: context) {
            for book in sp {
                var bookNode = ListObject(book.name ?? "Error: unidentified book")
                if let code = book.code, let chapters = book.chapters?.array as? [SpiritChapter] {
                    let sorted = chapters.sorted(by: {$0.index < $1.index})
                    for i in 0..<sorted.count {
                        bookNode.nested.append(
                            ListObject(
                                chapters[i].title ?? "Chapter \(chapters[i].number)",
                                nested: [],
                                index: SpiritIndex(book: code, chapter: i)
                            )
                        )
                    }
                }
                spirit.container.append(bookNode)
            }
        }
        return spirit
    }
    
}
