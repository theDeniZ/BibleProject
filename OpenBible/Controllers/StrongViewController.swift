//
//  StrongViewController.swift
//  OpenBible
//
//  Created by Denis Dobanda on 04.02.19.
//  Copyright © 2019 Denis Dobanda. All rights reserved.
//

import UIKit
import CoreData

class StrongViewController: UIViewController {
    
    var context: NSManagedObjectContext = AppDelegate.context
    var numbers: [Int] = []
    var identifier = StrongIdentifier.oldTestament

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var mainTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = "\(identifier) \(numbers.map({String($0)}).joined(separator: ", "))"
        if numbers.count > 0 {
            var out = "\n"
            for number in numbers {
                if let strong = Strong.get(number, by: identifier, from: context) {
                    if let org = strong.original {
                        out += "\(org)\n"
                    }
                    if let mean = strong.meaning {
                        out += "\(mean)\n\n"
                    }
                }
            }
            mainTextView.text = out
        }
    }
    
    @IBAction func closeAction(_ sender: Any) {
        if let nav = navigationController {
            nav.popViewController(animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
}
