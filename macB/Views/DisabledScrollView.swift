//
//  DisabledScrollView.swift
//  macB
//
//  Created by Denis Dobanda on 18.03.19.
//  Copyright © 2019 Denis Dobanda. All rights reserved.
//

import Cocoa

@IBDesignable
class DisabledScrollView: NSScrollView {
    
    @IBInspectable
    public var isEnabled: Bool = false
    
    public override func scrollWheel(with event: NSEvent) {
        if isEnabled {
            super.scrollWheel(with: event)
        }
        else {
            nextResponder?.scrollWheel(with: event)
        }
    }
}
