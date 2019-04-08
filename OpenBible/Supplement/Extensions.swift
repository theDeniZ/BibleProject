//
//  Extensions.swift
//  SplitB
//
//  Created by Denis Dobanda on 28.10.18.
//  Copyright © 2018 Denis Dobanda. All rights reserved.
//

import UIKit

extension NSAttributedString: StrongsLinkEmbeddable {
    var strongNumbersAvailable: Bool {
        return self.string.matches("(\\w \\d+ )")
    }
    
    func embedStrongs(to link: String, using size: CGFloat, linking: Bool = true) -> NSAttributedString {
        let newMAString = NSMutableAttributedString(string: " ", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: size)])
        let upperAttribute: [NSAttributedString.Key: Any] =
            [NSAttributedString.Key.baselineOffset : size * 0.333,
             NSAttributedString.Key.font : UIFont.italicSystemFont(ofSize: size * 0.666),
             .foregroundColor : UIColor.gray.withAlphaComponent(0.7)]
        
        let backColor = attribute(.backgroundColor, at: 1, effectiveRange: nil) as? UIColor
        let frontColor: UIColor? = UIColor.black//attribute(.foregroundColor, at: 1, effectiveRange: nil) as? UIColor
        
        
        let root = AppDelegate.URLServerRoot + link + "/"
        let splited = string.split(separator: " ").map {String($0)}
        newMAString.append(NSAttributedString(string: splited[0] + " ", attributes: upperAttribute))
        var i = 1
        while i < splited.count {
            if !("0"..."9" ~= splited[i][0]) { //splited[i].matches("\\d+") {
                let s = NSMutableAttributedString(string: splited[i])
                var numbers: [Int] = []
                while i < splited.count - 1, ("0"..."9" ~= splited[i + 1][0]) {//splited[i + 1].matches("\\d+") {
                    i += 1
                    let numberStr = splited[i].capturedGroups(withRegex: "(\\d+)")![0]
                    numbers.append(Int(numberStr)!)
                    if splited[i].count != numberStr.count {
                        s.append(NSAttributedString(string: splited[i].replacingOccurrences(of: numberStr, with: "")))
                    }
                }
                s.append(NSAttributedString(string: " "))
                if linking, numbers.count > 0 {
                    let url = root + numbers.map({String($0)}).joined(separator: "+")
                    s.addAttribute(NSAttributedString.Key.link, value: url, range: NSRange(0..<s.length - 1))
                }
                s.addAttributes([.font: UIFont.systemFont(ofSize: size)], range: NSRange(0..<s.length))
                newMAString.append(s)
            }
            i += 1
        }
        if let back = backColor {
            newMAString.addAttribute(.backgroundColor, value: back, range: NSRange(0..<newMAString.length))
        }
        if let front = frontColor {
            let start = splited[0].count + 1
            newMAString.addAttribute(.foregroundColor, value: front, range: NSRange(start..<newMAString.length))
        }
        return newMAString
    }
    
    func sizeFittingWidth(_ w: CGFloat) -> CGSize {
        let size = CGSize(width: w, height: CGFloat.greatestFiniteMagnitude)
        let textView = UITextView(frame: CGRect(origin: .zero, size: size))
        textView.attributedText = self
        let sizeToFit = textView.sizeThatFits(size)
        return sizeToFit
    }
}

extension UITextView {
    var rect: CGRect {
        return firstRect(
            for: textRange(
                from: position(from: beginningOfDocument, offset: 0)!,
                to: position(from: endOfDocument, offset: 0)!)!
        )
    }
}

extension Array {
    var countMax: Int {
        var m = 0
        for i in 0..<count {
            if let item = self[i] as? NSArray {
                m = Swift.max(m, item.count)
            }
        }
        return m
    }
}
