//
//  Extensions.swift
//  SplitB
//
//  Created by Denis Dobanda on 28.10.18.
//  Copyright © 2018 Denis Dobanda. All rights reserved.
//

import Cocoa

extension NSAttributedString: StrongsLinkEmbeddable {
    var strongNumbersAvailable: Bool {
        return self.string.matches("(\\w \\d+ )")
    }
    
    func embedStrongs(to link: String, using size: CGFloat, linking: Bool = true, withTooltip: Bool = false) -> NSAttributedString {
        let newMAString = NSMutableAttributedString()
        var normalFont = NSFont.systemFont(ofSize: size)
        var smallFont = NSFont.systemFont(ofSize: size * 0.666)
        if let named = AppDelegate.plistManager.getFont() {
            normalFont = NSFont(name: named, size: size)!
            smallFont = NSFont(name: named, size: size * 0.6)!
        }
        let backColor = attribute(.backgroundColor, at: 1, effectiveRange: nil) as? NSColor
        let frontColor = attribute(.foregroundColor, at: 1, effectiveRange: nil) as? NSColor
        
        var colorAttribute: [NSAttributedString.Key: Any]?
        var upperAttribute: [NSAttributedString.Key: Any] =
            [NSAttributedString.Key.baselineOffset : size * 0.333,
             NSAttributedString.Key.font : smallFont]
        
        if let c = NSColor(named: NSColor.Name("textColor")) {
            colorAttribute = [NSAttributedString.Key.foregroundColor : c]
            upperAttribute[NSAttributedString.Key.foregroundColor] = c
        }
        let splited = string.replacingOccurrences(of: "\r\n", with: "").split(separator: " ").map {String($0)}
        newMAString.append(NSAttributedString(string: splited[0] + " ", attributes: upperAttribute))
        let url = AppDelegate.URLServerRoot + link + "/"
        var i = 1
        while i < splited.count {
            if !("0"..."9" ~= splited[i][0]) {// !splited[i].matches("\\d+") {
                let s = NSMutableAttributedString(string: splited[i])
                var numbers: [Int] = []
                while i < splited.count - 1, ("0"..."9" ~= splited[i + 1][0]) {//splited[i + 1].matches("\\d+") {
                    i += 1
                    if let n = Int(splited[i]) {
                        numbers.append(n)
                    } else {
                        let numberStr = splited[i].capturedGroups(withRegex: "(\\d+)")![0]
                        numbers.append(Int(numberStr)!)
                        if splited[i].count != numberStr.count {
                            s.append(NSAttributedString(string: splited[i].replacingOccurrences(of: numberStr, with: "")))
                        }
                    }
                }
                s.append(NSAttributedString(string: " "))
                if let c = colorAttribute {
                    s.addAttributes(c, range: NSRange(0..<s.length))
                }
                if linking, numbers.count > 0 {
                    let ns = numbers.map({String($0)}).joined(separator: "+")
                    
                    s.addAttribute(.link, value: url + ns, range: NSRange(0..<s.length - 1))
                    if withTooltip {
                        s.addAttribute(.toolTip, value: StrongManager.getTooltip(from: ns, type: link), range: NSRange(0..<s.length - 1))
                    } else {
                        s.addAttribute(.toolTip, value: "Turn on toolitp in settings", range: NSRange(0..<s.length - 1))
                    }
//                    s.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single, range: NSRange(0..<s.length - 1))
                }
                s.addAttributes([.font: normalFont], range: NSRange(0..<s.length))
                newMAString.append(s)
            }
            i += 1
        }
//        if !newMAString.string.hasSuffix("\n ") {
//            newMAString.append(NSAttributedString(string: "\n"))
//        }
        if let back = backColor {
            newMAString.addAttribute(.backgroundColor, value: back, range: NSRange(0..<newMAString.length))
        }
        if let front = frontColor {
            newMAString.addAttribute(.foregroundColor, value: front, range: NSRange(0..<newMAString.length))
        }
        return newMAString
    }
    
    func sizeFittingWidth(_ w: CGFloat) -> CGSize {
        let size = CGSize(width: w, height: CGFloat.greatestFiniteMagnitude)
        let textContainer = NSTextContainer(size: size)
        let textStorage = NSTextStorage(attributedString: self)
        let layoutManager = NSLayoutManager()
        
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        textContainer.lineFragmentPadding = 0.0
        
        layoutManager.glyphRange(for: textContainer)
        let rect = layoutManager.usedRect(for: textContainer)
        return rect.size
    }
    
}

extension NSColor {
    func invert() -> NSColor {
        var red         :   CGFloat  =   255.0
        var green       :   CGFloat  =   255.0
        var blue        :   CGFloat  =   255.0
        var alpha       :   CGFloat  =   1.0
        
        self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        red     =   255.0 - (red * 255.0)
        green   =   255.0 - (green * 255.0)
        blue    =   255.0 - (blue * 255.0)
        
        return NSColor(red: red / 255.0, green: green / 255.0, blue: blue / 255.0, alpha: alpha)
    }
}
