//
//  FileManagerViewController.swift
//  macB
//
//  Created by Denis Dobanda on 24.12.18.
//  Copyright © 2018 Denis Dobanda. All rights reserved.
//

import Cocoa

class FileManagerViewController: NSViewController {

    @IBOutlet weak var progressBar: NSProgressIndicator!
    @IBOutlet weak var dropView: DropView!
    @IBOutlet weak var dropImageView: DropImageView!
    
    var context: NSManagedObjectContext = AppDelegate.context
    
    private var countOfAllObjects: Int = 0
    private var completed: Int = 0 {
        didSet {
            if countOfAllObjects > 0 {
                progressBar?.doubleValue = Double(completed) / Double(countOfAllObjects)
            } else {
                progressBar?.doubleValue = 0.0
            }
            setTimer()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dropView.delegate = self
//        dropImageView.delegate = self
    }
    
    private func setTimer() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { (t) in
            t.invalidate()
            self.countOfAllObjects = 0
            self.completed = 0
        }
    }
}


extension FileManagerViewController: DragDelegate {
    func dragCompleted(with path: String) {
//        print(path)
        let manager = FileManager(path, in: context)
        manager.delegate = self
        manager.initiateParsing()
        
    }
}

extension FileManagerViewController: DownloadProgressDelegate {
    func downloadCompleted(with success: Bool, at number: Int, of: Int) {
        DispatchQueue.main.async { [weak self] in
            self?.dropView.completedAction(with: success)
            if self?.countOfAllObjects != of {
                self?.countOfAllObjects = of
                self?.completed = 0
            }
            self?.completed += 1
        }
    }
}
