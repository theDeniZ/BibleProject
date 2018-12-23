//
//  ModelUpdateProtocol.swift
//  macB
//
//  Created by Denis Dobanda on 23.12.18.
//  Copyright © 2018 Denis Dobanda. All rights reserved.
//

import Foundation

protocol ModelUpdateDelegate {
    var hashValue: Int {get}
    func modelChanged()
    
}
