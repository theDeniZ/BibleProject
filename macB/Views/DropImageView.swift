//
//  DragView.swift
//  macB
//
//  Created by Denis Dobanda on 24.12.18.
//  Copyright © 2018 Denis Dobanda. All rights reserved.
//

import Cocoa

class DropImageView: NSImageView {
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        unregisterDraggedTypes()
    }
    
}
