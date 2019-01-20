import Foundation

struct ListRoot {
    var typeName: String = ""
    var container: [ListObject] = []
}

struct ListObject {
    var title: String = ""
    var nested: [ListObject] = []
    
    init(_ title: String) {
        self.title = title
    }
    
    init(_ title: String, nested: [ListObject]) {
        self.title = title
        self.nested = nested
    }
}

class ListManager: NSObject {
    
    var context = AppDelegate.context
    
    func getListOfAll() -> [ListRoot] {
        var allOfThem = [ListRoot]()
        
        var bibles = ListRoot(typeName: "Bible", container: [])
        if let modules = try? Module.getAll(from: context) {
            for module in modules {
                let name = module.name ?? module.key ?? "Error: unidentified module"
                var bible = ListObject(name)
                if let books = module.books?.array as? [Book] {
                    let sorted = books.sorted {$0.number < $1.number}
                    for book in sorted {
                        let bookName = book.name ?? "Book \(book.number)"
                        var listBook = ListObject(bookName)
                        let count = book.chapters?.array.count ?? 0
                        let number = ListObject("\(count) Chapter\(count > 1 ? "s" : "")")
                        listBook.nested = [number]
                        bible.nested.append(listBook)
                    }
                }
                bibles.container.append(bible)
            }
        }
        allOfThem.append(bibles)
        
        var strongs = ListRoot(typeName: "Strong's Numbers", container: [])
        for str in StrongNumbers.allCases {
            let count = Strong.count(of: str.rawValue, in: context)
            if count > 0 {
                let s = ListObject(str.rawValue, nested: [ListObject("\(count)")])
                strongs.container.append(s)
            }
        }
        allOfThem.append(strongs)
        
        if let sp = try? SpiritBook.getAll(from: context) {
            var spirit = ListRoot(typeName: "Spirit of Prophecy", container: [])
            for book in sp {
                var bookNode = ListObject(book.name ?? "Error: unidentified book")
                if let chapters = book.chapters?.array as? [SpiritChapter] {
                    let sorted = chapters.sorted(by: {$0.index < $1.index})
                    for chapter in sorted {
                        bookNode.nested.append(ListObject(chapter.title ?? "Chapter \(chapter.number)"))
                    }
                }
                spirit.container.append(bookNode)
            }
            allOfThem.append(spirit)
        }
        
        return allOfThem
    }
    
}
