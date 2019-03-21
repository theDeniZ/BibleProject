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
    var resignDelegate: UIResignDelegate?
    var makingCustomSize: Bool = true
    
    @IBOutlet private weak var mainTextView: UITextView!
    @IBOutlet weak var topSpace: NSLayoutConstraint!
    @IBOutlet weak var colorStack: UIStackView!
    @IBOutlet weak var closeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mainTextView.text = delegate?.isThereANote(at: index)
        if makingCustomSize {
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIApplication.keyboardWillShowNotification, object: nil)
            
            topSpace.constant += view.bounds.height / 2
            view.backgroundColor = UIColor.white.withAlphaComponent(0)
            let over = UIView(frame: CGRect(origin: CGPoint(x: 0, y: view.frame.size.height / 2), size: view.bounds.size))
            over.backgroundColor = UIColor.white
            view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(touch(_:))))
            view.insertSubview(over, at: 0)
        }
        if UIDevice.current.userInterfaceIdiom != .phone {
            closeButton.isHidden = true
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        resignDelegate?.viewControllerWillResign()
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
    
    @objc private func touch(_ sender: UITapGestureRecognizer) {
        if sender.location(in: view).y < view.bounds.height / 2 {
            resignDelegate?.viewControllerWillResign()
            dismiss(animated: true, completion: nil)
        }
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        if let keyboardHeight = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height {
            colorStack.isHidden = true
            if view.frame.origin.y >= 0 {
                UIView.animate(withDuration: 1.0) {
                    self.view.frame.origin.y -= keyboardHeight// = CGRect(origin: CGPoint(x: 0, y: self.view.frame.origin.y - keyboardHeight), size: self.view.frame.size)
                }
            }
        }
    }
    
}
