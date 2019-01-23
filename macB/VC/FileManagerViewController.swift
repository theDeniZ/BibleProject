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
    
    @IBOutlet weak var customTextViewContainer: NSView!
    @IBOutlet var outputTextView: NSTextView!
    
    
    var context: NSManagedObjectContext = AppDelegate.context
    
    private var countOfAllObjects: Int = 0
    private var completed: [(name: String, status: Bool)] = [] {
        didSet {
            if progressBar.isIndeterminate {
                progressBar.stopAnimation(nil)
                progressBar.isIndeterminate = false
            }
            if countOfAllObjects > 0 {
                progressBar?.doubleValue = Double(completed.count) / Double(countOfAllObjects)
                showOutput()
            } else {
                progressBar?.doubleValue = 0.0
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dropView.delegate = self
//        dropImageView.delegate = self
    }
    
    private func setTimer() {
        Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { (t) in
            t.invalidate()
            self.countOfAllObjects = 0
            self.completed = []
            self.customTextViewContainer.isHidden = true
        }
    }
    
    private func showOutput() {
        customTextViewContainer.isHidden = false
        var output = "Reading progress:\n"
        for module in completed {
            output += "\(module.name)\t-\t\(module.status ? "success" : "failure")\n"
        }
        outputTextView.string = output
        outputTextView.scrollToEndOfDocument(nil)
    }
}


extension FileManagerViewController: DragDelegate {
    func dragCompleted(with path: String) {
//        print(path)
        let manager = FileManager(path)
        manager.delegate = self
        manager.initiateParsing()
        showOutput()
        progressBar.isIndeterminate = true
        progressBar.startAnimation(nil)
    }
}

extension FileManagerViewController: DownloadProgressDelegate {
    func downloadStarted(with pendingNumber: Int) {
        DispatchQueue.main.async { [weak self] in
            self?.countOfAllObjects = pendingNumber
        }
    }
    
    func downloadFinished() {
        DispatchQueue.main.async { [weak self] in
            self?.setTimer()
        }
    }
    
    func downloadCompleted(with success: Bool, at name: String) {
        DispatchQueue.main.async { [weak self] in
            self?.completed.append((name, success))
        }
    }
}
