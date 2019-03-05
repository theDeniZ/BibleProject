//
//  ProgressView.swift
//  OpenBible
//
//  Created by Denis Dobanda on 21.02.19.
//  Copyright © 2019 Denis Dobanda. All rights reserved.
//

import UIKit

class ProgressView: UIView {
    
    var firstColor: UIColor = UIColor.green
    var secondColor: UIColor = UIColor.red
    
    private var gradientLayer: CAGradientLayer!
    private var gradient = CAGradientLayer()
    private var animation: CABasicAnimation!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialiseGradient()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialiseGradient()
    }
    
    private func initialiseGradient() {
        gradient.frame = bounds
        gradient.startPoint = CGPoint(x:0.0, y:0.0)
        gradient.endPoint = CGPoint(x:1.0, y:0.0)
        gradient.colors = [firstColor.cgColor, secondColor.cgColor, firstColor.cgColor, secondColor.cgColor, firstColor.cgColor, secondColor.cgColor]
        gradient.locations =  [-1.3333, -0.6666, -0.3333, 0.3333, 0.6666, 1.3333]
        
        layer.addSublayer(gradient)
    }
    
    func startAnimating() {
        animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [-1.3333, -0.6666, -0.3333, 0.3333, 0.6666, 1.3333]
        animation.toValue = [-0.6666, 0.3333, 0.6666, 1.3333, 1.6666, 2.0]
        animation.duration = 1.0
        animation.autoreverses = false
        animation.repeatCount = Float.infinity
        
        gradient.add(animation, forKey: "anim")
    }
    
    func stopAnimating() {
        gradient.removeAnimation(forKey: "anim")
    }

}
