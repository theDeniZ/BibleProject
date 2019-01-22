//
//  SpiritHTMLParser.swift
//  macB
//
//  Created by Denis Dobanda on 20.01.19.
//  Copyright © 2019 Denis Dobanda. All rights reserved.
//

import Foundation
import SwiftSoup
import HTMLString

enum SpiritBookIdentifier: String {
    case main = "first.htm"
}

class SpiritHTMLParser: NSObject {
    
    var context: NSManagedObjectContext = AppDelegate.context
    
    private let pageNumberRegex = "\\[(\\d+)\\]"
    
    static var shared: SpiritHTMLParser = SpiritHTMLParser()
    
    func parseSpiritBook(_ path: String, with delegate: DownloadProgressDelegate?, completed: (() -> ())? = nil) {
        func finish(_ status: Bool = false) {
            delegate?.downloadCompleted(with: status, at: path)
            completed?()
        }
        
        guard let codeName = path.split(separator: "/").last else {finish();return}
        let code = String(codeName)
        if let existed = try? SpiritBook.get(by: code, from: context), existed != nil {
            context.delete(existed!)
        }
        
        guard
            let html = try? String(contentsOfFile: path + SpiritBookIdentifier.main.rawValue),
            let doc: Document = try? SwiftSoup.parse(html),
            let links: Elements = try? doc.select("a")
        else {print("Cannot read and parse html");finish();return}
        var title: String! = try? doc.select("td").array().filter({ if let className = try? $0.className(), className == "tcenter" {return true} else {return false}})[0].text()
        if title == nil {
            title = try? doc.title()
        }
        guard title != nil else {print("Cannot find title"); finish(); return}
        
        let book = SpiritBook(context: context)
        book.code = code
        book.name = title
        
        var chapters = [SpiritChapter]()
        let linksArray = links.array()
        for i in 0..<linksArray.count {
            do {
                let linkHref: String = try linksArray[i].attr("href")
                let linkText: String = try linksArray[i].text()
                let chapterNumber = Int(linkHref.split(separator: ".")[0])
                if let chapter = parseChapter(on: path + linkHref) {
                    if let n = chapterNumber {chapter.number = Int32(n)}
                    chapter.title = linkText
                    chapter.index = Int32(i)
                    chapters.append(chapter)
                }
            } catch {
                print("Link parsing: " + error.localizedDescription)
                finish()
                return
            }
        }
        book.chapters = NSOrderedSet(array: chapters)
        try? context.save()
        finish(true)
    }
    
    private func parseChapter(on path: String) -> SpiritChapter? {
        if let html = try? String(contentsOfFile: path) {
            let stripped = html.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
//                                .replacingOccurrences(of: "\r", with: "")
                                .removingHTMLEntities
            let array = stripped.split(separator: "\r\n").map {String($0)}
            let chapter = SpiritChapter(context: context)
            var i = 0
            var intro = ""
            while i < array.count, !array[i].matches(pageNumberRegex) {
                intro += array[i] + "\n"
                i += 1
            }
            chapter.intro = intro
            var pages = [Page]()
            while i < array.count {
                if array[i].matches(pageNumberRegex) {
                    let num = array[i].capturedGroups(withRegex: pageNumberRegex)![0]
                    var number: Int = 0
                    var roman = false
                    if let n = Int(num) {
                        number = n
                    } else if let n = Int(roman: num) {
                        number = n
                        roman = true
                    }
                    var content = ""
                    i += 1
                    while i < array.count, !array[i].matches(pageNumberRegex) {
                        content += array[i] + "\n"
                        i += 1
                    }
                    let page = Page(context: context)
                    page.chapter = chapter
                    page.number = Int32(number)
                    page.roman = roman
                    page.text = content
                    pages.append(page)
                } else {
                    i += 1
                }
            }
            chapter.pages = NSOrderedSet(array: pages)
            return chapter
        }
        return nil
    }
}
