//
//  NoteViewController.swift
//  OpenBible
//
//  Created by Denis Dobanda on 20.03.19.
//  Copyright © 2019 Denis Dobanda. All rights reserved.
//

import UIKit

struct ColorPicker {
    static let yellow   = UIColor(red: 1.0, green: 253/255, blue: 56/255, alpha: 1.0)
    static let red      = UIColor(red: 242/255, green: 93/255, blue: 93/255, alpha: 1.0)
    static let orange   = UIColor(red: 243/255, green: 161/255, blue: 87/255, alpha: 1.0)
    static let green    = UIColor(red: 91/255, green: 204/255, blue: 145/255, alpha: 1.0)
    static let blue     = UIColor(red: 71/255, green: 145/255, blue: 240/255, alpha: 1.0)
}

class NoteViewController: UIViewController {

    var index: (Int, Int) = (0,0)
    var delegate: ModelVerseDelegate?
    
    @IBOutlet weak var mainTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mainTextView.text = delegate?.isThereANote(at: index)

//        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(touch(_:))))
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIApplication.keyboardWillShowNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(UIViewController.keyboardWillShowNotification), name: UIApplication.keyboardWillShowNotification, object: nil)
//
//        NotificationCenter.default.addObserver(self, selector: #selector(UIViewController.keyboardWillHideNotification), name: UIApplication.keyboardWillHideNotification, object: nil)
    }

    @IBAction func clearAction(_ sender: UIButton) {
        delegate?.setNote(at: index, nil)
        dismiss(animated: true, completion: nil)
    }
    @IBAction func closeAction(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveAction(_ sender: UIButton) {
        if let text = mainTextView.text, text.count > 0 {
            delegate?.setNote(at: index, text)
        } else {
            delegate?.setNote(at: index, nil)
        }
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func yellowAction(_ sender: UIButton) {
        setColor(ColorPicker.yellow)
    }
    @IBAction func redAction(_ sender: UIButton) {
        setColor(ColorPicker.red)
    }
    @IBAction func orangeAction(_ sender: UIButton) {
        setColor(ColorPicker.orange)
    }
    @IBAction func greenAction(_ sender: UIButton) {
        setColor(ColorPicker.green)
    }
    @IBAction func blueAction(_ sender: UIButton) {
        setColor(ColorPicker.blue)
    }
    @IBAction func clearColorAction(_ sender: UIButton) {
        delegate?.setColor(at: index, nil)
        dismiss(animated: true, completion: nil)
    }
    
    private func setColor(_ color: UIColor) {
        delegate?.setColor(at: index, NSKeyedArchiver.archivedData(withRootObject: color))
        dismiss(animated: true, completion: nil)
    }
    
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardHeight = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height {

            UIView.animate(withDuration: 1.0) {
                self.view.frame = CGRect(origin: CGPoint(x: 0, y: self.view.frame.origin.y - keyboardHeight), size: self.view.frame.size)
            }
//             = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
        }
    }
//
//    @objc func keyboardWillHide(notification: NSNotification) {
//        UIView.animate(withDuration: 0.2, animations: {
//            // For some reason adding inset in keyboardWillShow is animated by itself but removing is not, that's why we have to use animateWithDuration here
//            self.webView.scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//        })
//    }
    
}
