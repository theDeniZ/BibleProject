//
//  DownloadProtocol.swift
//  macB
//
//  Created by Denis Dobanda on 21.12.18.
//  Copyright © 2018 Denis Dobanda. All rights reserved.
//

import Foundation

protocol DownloadDelegate {
    func initiateDownload(by key: String)
    func initiateRemoval(by key: String)
}

extension DownloadDelegate {
    func initiateDownload(by key: String, completition: ((Bool) -> Void)? = nil) {}
    func initiateRemoval(by key: String, completition: ((Bool) -> Void)? = nil) {}
}
