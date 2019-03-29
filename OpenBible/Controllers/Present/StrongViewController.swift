//
//  StrongViewController.swift
//  OpenBible
//
//  Created by Denis Dobanda on 04.02.19.
//  Copyright © 2019 Denis Dobanda. All rights reserved.
//

import UIKit
import CoreData

class StrongViewController: UIViewController, Storyboarded {
    
//    var context: NSManagedObjectContext = AppDelegate.viewContext
//    var numbers: [Int] = []
//    var identifier = StrongId.oldTestament
    
    var coordinator: MainStrongCoordinator!

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var mainTextView: UITextView!
    @IBOutlet weak var closeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = coordinator.title
        mainTextView.text = coordinator.text
        if navigationController != nil {
            navigationItem.title = titleLabel.text
            titleLabel.isHidden = true
            closeButton.isHidden = true
        }
        mainTextView.contentOffset = CGPoint(x: 0, y: 0)
    }
    
    @IBAction func closeAction(_ sender: Any) {
//        if let nav = navigationController {
//            nav.popViewController(animated: true)
//        } else {
//            dismiss(animated: true, completion: nil)
//        }
        coordinator.dismiss()
    }
    
}
