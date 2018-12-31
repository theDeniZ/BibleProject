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
    
    private var original: String?
    private var detail: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }
    
    private func updateUI() {
        var out = ""
        if let n = numbers {
            for number in n {
                if let s = Strong.get(number, by: identifierStrong, from: context) {
                    let org = s.original ?? ""
                    let mean = s.meaning ?? ""
//                    if identifierStrong == StrongIdentifier.oldTestament {
                        out += "<\(s.number)>\n\n"
                    out += "\(org)\n\n"
                    out += "\(mean)\n\n"
//                    } else {
//                        out += "<\(s.number)> - \(org)\n\(mean)\n\n"
//                    }
                }
            }
        }
        detailTextView?.string = out
    }
}
