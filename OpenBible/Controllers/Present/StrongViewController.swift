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
    
    var context: NSManagedObjectContext = AppDelegate.viewContext
    var numbers: [Int] = []
    var identifier = StrongId.oldTestament

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var mainTextView: UITextView!
    @IBOutlet weak var closeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = "\(identifier) \(numbers.map({String($0)}).joined(separator: ", "))"
        if numbers.count > 0 {
            var out = "\n"
            for number in numbers {
                if let strong = Strong.get(number, by: identifier, from: context) {
                    if let org = strong.original {
                        out += "\(org)\n\n"
                    }
                    if let mean = strong.meaning {
                        out += "\(mean)\n\n"
                    }
                }
            }
            mainTextView.text = out
        }
        if navigationController != nil {
            navigationItem.title = titleLabel.text
            titleLabel.isHidden = true
            closeButton.isHidden = true
        }
//        mainTextView.scrollRectToVisible(CGRect(x: 0, y: 0, width: 0, height: 0), animated: false)
        mainTextView.contentOffset = CGPoint(x: 0, y: 0)
    }
    
    @IBAction func closeAction(_ sender: Any) {
        if let nav = navigationController {
            nav.popViewController(animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
}
