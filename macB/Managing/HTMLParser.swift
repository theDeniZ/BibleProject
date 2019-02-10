//
//  HTMLParser.swift
//  macB
//
//  Created by Denis Dobanda on 24.12.18.
//  Copyright © 2018 Denis Dobanda. All rights reserved.
//

import Foundation
import CoreData

class HTMLParser: NSObject {
    
    let root: String
    var current: Int
    let context: NSManagedObjectContext
    var encoding: String.Encoding?
    
    init(_ path: String, start: Int, context: NSManagedObjectContext) {
        root = path
        current = start
        self.context = context
        super.init()
    }
    
    func parse(_ dataArray: [(path: String, name: String)], to module: Module) -> Bool {
        var bookArray: [Book] = []
        for i in current..<current + dataArray.count {
            if let book = parseBookfFromFile(withInfo: dataArray[i - current]) {
                book.number = Int32(i)
                book.module = module
                bookArray.append(book)
            } else {
                return false
            }
        }
        module.books = NSOrderedSet(array: bookArray)
        return true
    }
    
    private func parseBookfFromFile(withInfo: (name: String, path: String)) -> Book? {
        var htm: String?
        if let enc = encoding {
            htm = try? String(contentsOf: URL(fileURLWithPath: root + withInfo.path), encoding: enc)
        } else {
            htm = try? String(contentsOf: URL(fileURLWithPath: root + withInfo.path))
        }
        if let html = htm {
            
            let stripped = html.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
            let bookArray = stripped.split(separator: "\r\n").map {String($0)}
            
            var chapters: [Chapter] = []
            var index = 0
            while index < bookArray.count {
                if let pattern = matchesChapter(bookArray[index], with: withInfo.name) {
                    var chapterNumber: Int = 0
                    switch pattern {
                    case .withNameInFront:
                        chapterNumber = Int(bookArray[index].capturedGroups(withRegex: withInfo.name + pattern.rawValue)![0])!
                    default:
                        chapterNumber = Int(bookArray[index].capturedGroups(withRegex: pattern.rawValue)![0])!
                    }
                    let chapter = Chapter(context: context)
                    chapter.number = Int32(chapterNumber)
                    
                    var verses: [Verse] = []
                    while index < bookArray.count &&
                        (!bookArray[index].matches("(\\d+) (.+)") ||
                            matchesChapter(bookArray[index], with: withInfo.name) != nil
                        ) {index += 1}
                    //here index at first verse.
                    while index < bookArray.count &&
                        bookArray[index].matches("(\\d+) (.+)") &&
                        matchesChapter(bookArray[index], with: withInfo.name) != .withNameInFront
                        {
                        let verseGroups = bookArray[index].capturedGroups(withRegex: "(\\d+) (.+)")!
                        let verseNumber = Int(verseGroups[0])!
                        var verseText = verseGroups[1]
                        index += 1
                        
                        while index < bookArray.count &&
                            !bookArray[index].matches("(\\d+) (.+)") &&
                            matchesChapter(bookArray[index], with: withInfo.name) == nil {
                            verseText += bookArray[index]
                            index += 1
                        }
                        let verse = Verse(context: context)
                        verse.number = Int32(verseNumber)
                        verse.text = verseText + "\r\n"
                        verse.chapter = chapter
                        verses.append(verse)
                    }
                    
                    chapter.verses = NSOrderedSet(array: verses)
                    chapters.append(chapter)
                } else {
                    index += 1
                }
//                index += 1
            }
            
            let book = Book(context: context)
            book.name = withInfo.name
            book.chapters = NSOrderedSet(array: chapters)
            return book
        }
        return nil
    }
    
    private func matchesChapter(_ text: String, with name: String) -> ChapterPattern? {
        for pattern in ChapterPattern.allCases {
            if pattern == .withNameInFront {
                if text.matches("^" + name + pattern.rawValue) {
                    return pattern
                }
            } else {
                if text.matches(pattern.rawValue) {
                    return pattern
                }
            }
        }
        return nil
    }

    func parseHtmlFile(_ named: String = "") -> Bool {
        var htm: String?
        if let enc = encoding {
            htm = try? String(contentsOf: URL(fileURLWithPath: root), encoding: enc)
        } else {
            do {
                htm = try String(contentsOf: URL(fileURLWithPath: root))
            } catch {
                print("Opening error: \(error)")
                do {
                    htm = try String(contentsOf: URL(fileURLWithPath: root), encoding: .utf8)
                } catch {
                    print("!!Not an utf8!! \(error)")
                }
            }
        }
        if let html = htm {
            let name = named.contains("hebrew") ? "Hebrew" : "Greek"
            let stripped = html.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
            var fileArray = stripped.split(separator: "\r\n").map {String($0)}
            if fileArray.count == 1 {
                fileArray = stripped.split(separator: "\n").map {String($0)}
            }
            let regexForStart = "^[0]*(\\d+)$"
            let regexForMeaning = "^[(:']?\\w+"
            
            var i = 0
            while i < fileArray.count {
                if fileArray[i].matches(regexForStart) {
                    let number = Int(fileArray[i].capturedGroups(withRegex: regexForStart)![0])!
                    i += 1
                    let regexForLine = "(?:\(number), )(.*)"
                    while i < fileArray.count,
                        !fileArray[i].matches(regexForLine),
                        !fileArray[i].matches(regexForStart),
                        !fileArray[i].matches(regexForMeaning) {i += 1}
                    if i < fileArray.count, !fileArray[i].matches(regexForStart) {
                        var original: String? = nil
                        if fileArray[i].matches(regexForLine) {
                            original = fileArray[i].capturedGroups(withRegex: regexForLine)![0]
                            i += 1
                        }
                        var meaning = ""
                        while i < fileArray.count, !fileArray[i].matches(regexForStart) {
                            meaning.append(fileArray[i] + "\n")
                            i += 1
                        }
                        if let strong = Strong.get(number, by: name, from: context) {
                            if let m = strong.meaning {
                                strong.meaning = meaning + "\n\n" + m
                            } else {
                                strong.meaning = meaning
                            }
                        } else {
                            let strong = Strong(context: context)
                            strong.number = Int32(number)
                            if let org = original {
                                strong.original = org
                            }
                            strong.meaning = meaning
                            strong.type = name
                        }
                    }
                } else {
                    i += 1
                }
            }
            do {
                try context.save()
                return true
            } catch {
                print(error)
                return false
            }
            
        }
        return false
    }
    
}

enum ChapterPattern: String, CaseIterable {
    case withNameInFront = "[,]? (\\d+)[.]?$"
    case withChapter = "^(?i)Chapter (\\d+)[.]?$"
    case withNumber = "^(\\d+)[.]?$"
    case withCustomName = "^\\w+ (\\d+)[.]?$"
}
