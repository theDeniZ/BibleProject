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
             NSAttributedString.Key.font : UIFont.systemFont(ofSize: size * 0.666)]
        let splited = string.replacingOccurrences(of: "\r\n", with: "").split(separator: " ").map {String($0)}
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
                    let url = link + numbers.map({String($0)}).joined(separator: "+")
                    s.addAttribute(NSAttributedString.Key.link, value: url, range: NSRange(0..<s.length - 1))
                }
                s.addAttributes([.font: UIFont.systemFont(ofSize: size)], range: NSRange(0..<s.length))
                newMAString.append(s)
            }
            i += 1
        }
        newMAString.append(NSAttributedString(string: "\r\n"))
        return newMAString
    }
}
