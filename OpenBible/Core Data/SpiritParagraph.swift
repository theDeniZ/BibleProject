//
//  SpiritParagraph.swift
//  OpenBible
//
//  Created by Denis Dobanda on 05.04.19.
//  Copyright © 2019 Denis Dobanda. All rights reserved.
//

import UIKit
import CoreData

class SpiritParagraph: NSManagedObject {
    
    var compound: String {
        if let t = text {
            return t//"\(t[...t.index(t.endIndex, offsetBy: -2)])"
        }
        return ""
    }
    
    var attributedCompound: NSAttributedString {
        let att = NSMutableAttributedString(string: compound)
        if let colorData = color, let color = NSKeyedUnarchiver.unarchiveObject(with: colorData) as? UIColor {
            att.addAttribute(.backgroundColor, value: color, range: NSRange(0..<att.length))
        }
        return att
    }
    
    func attributedCompound(font: UIFont) -> NSAttributedString {
        let mutable = NSMutableAttributedString(attributedString: attributedCompound)
        mutable.addAttributes([.font: font], range: NSRange(0..<mutable.length))
        return mutable
    }
}
