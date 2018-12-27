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
        if var html: String = try? String(contentsOf: URL(fileURLWithPath: root + withInfo.path), encoding: encoding ?? .utf8) {
            
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
                if text.matches(name + pattern.rawValue) {
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
}

enum ChapterPattern: String, CaseIterable {
    case withNameInFront = "[,]? (\\d+)[.]?$"
    case withChapter = "(?i)Chapter (\\d+)[.]?$"
    case withNumber = "^(\\d+)[.]?$"
    case withCustomName = "^\\w+ (\\d+)[.]?$"
}
