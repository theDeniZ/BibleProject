//
//  ProgressView.swift
//  OpenBible
//
//  Created by Denis Dobanda on 21.02.19.
//  Copyright © 2019 Denis Dobanda. All rights reserved.
//

import UIKit

class ProgressView: UIView, Progressable {

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initProgress()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initProgress()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layoutProgress()
    }

}
