//
//  StrongDetailViewController.swift
//  macB
//
//  Created by Denis Dobanda on 30.12.18.
//  Copyright © 2018 Denis Dobanda. All rights reserved.
//

import Cocoa

class StrongDetailViewController: NSViewController {

    var numbers: [Int]?
    var identifierStrong: String = StrongIdentifier.oldTestament
    var context: NSManagedObjectContext = AppDelegate.context
    
    @IBOutlet private var detailTextView: NSTextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
        title = "Strong Detail (\(identifierStrong))"
    }
    
    private func updateUI() {
        var out = ""
        if let n = numbers {
            for number in n {
                if let s = Strong.get(number, by: identifierStrong, from: context) {
                    out += "<\(s.number)>\n\n"
                    out += "\(s.original ?? "")\n\n"
                    out += "\(s.meaning ?? "")\n\n"
                }
            }
        }
        detailTextView?.string = out
    }
}
