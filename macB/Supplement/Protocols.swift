//
//  DownloadProtocol.swift
//  macB
//
//  Created by Denis Dobanda on 21.12.18.
//  Copyright © 2018 Denis Dobanda. All rights reserved.
//

import Foundation

protocol DownloadDelegate {
    func initiateDownload(by key: String, completition: ((Bool) -> Void)?)
    func initiateRemoval(by key: String, completition: ((Bool) -> Void)?)
}

extension DownloadDelegate {
    func initiateDownload(by key: String, completition: ((Bool) -> Void)? = nil) {}
    func initiateRemoval(by key: String, completition: ((Bool) -> Void)? = nil) {}
}

protocol ModelUpdateDelegate {
    var hashValue: Int {get}
    func modelChanged()
    
}

protocol DragDelegate {
    func dragCompleted(with path: String)
}

protocol DownloadProgressDelegate {
    func downloadCompleted(with success: Bool, at number: Int, of: Int)
}
