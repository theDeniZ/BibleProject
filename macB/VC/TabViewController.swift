//
//  TabViewController.swift
//  macB
//
//  Created by Denis Dobanda on 24.12.18.
//  Copyright © 2018 Denis Dobanda. All rights reserved.
//

import Cocoa

class TabViewController: NSTabViewController {

//    override func viewDidLoad() {
//        super.viewDidLoad()
//        // Do view setup here.
//    }

    
    override func viewWillAppear() {
        super.viewWillAppear()
        preferredContentSize = NSSize(width: 600, height: 400)
    }
}
