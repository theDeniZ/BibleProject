//
//  ColorPickerView.swift
//  macB
//
//  Created by Denis Dobanda on 19.03.19.
//  Copyright © 2019 Denis Dobanda. All rights reserved.
//

import Cocoa

struct ColorPicker {
    static let yellow   = NSColor(deviceRed: 1.0, green: 253/255, blue: 56/255, alpha: 1.0)
    static let red      = NSColor(deviceRed: 242/255, green: 93/255, blue: 93/255, alpha: 1.0)
    static let orange   = NSColor(deviceRed: 243/255, green: 161/255, blue: 87/255, alpha: 1.0)
    static let green    = NSColor(deviceRed: 91/255, green: 204/255, blue: 145/255, alpha: 1.0)
    static let blue     = NSColor(deviceRed: 71/255, green: 145/255, blue: 240/255, alpha: 1.0)
}

class ColorPickerView: NSView {
    
    var delegate: ModelVerseDelegate?
    var index: (Int, Int) = (0,0)
    
    @IBAction private func yellowAction(_ sender: NSButton) {
        returnColor(ColorPicker.yellow)
    }
    
    @IBAction private func redAction(_ sender: NSButton) {
        returnColor(ColorPicker.red)
    }
    
    @IBAction private func orangeColor(_ sender: NSButton) {
        returnColor(ColorPicker.orange)
    }
    
    @IBAction private func greenAction(_ sender: NSButton) {
        returnColor(ColorPicker.green)
    }
    
    @IBAction private func blueAction(_ sender: NSButton) {
        returnColor(ColorPicker.blue)
    }
    
    @IBAction func clearAction(_ sender: NSButton) {
        delegate?.setColor(at: index, nil)
    }
    
    
    private func returnColor(_ color: NSColor) {
        delegate?.setColor(at: index, NSKeyedArchiver.archivedData(withRootObject: color))
    }
}
