//
//  Crypto.swift
//  macB
//
//  Created by Denis Dobanda on 27.04.19.
//  Copyright © 2019 Denis Dobanda. All rights reserved.
//

import Foundation
import CommonCrypto

extension String {
    
    // MARK: - SHA256
    func SHA256() -> String {
        guard let data = self.data(using: .utf8) else {
            print("Data not available")
            return ""
        }
        return getHexString(fromData: digest(input: data as NSData))
    }
    
    private func digest(input : NSData) -> NSData {
        let digestLength = Int(CC_SHA256_DIGEST_LENGTH)
        var hashValue = [UInt8](repeating: 0, count: digestLength)
        CC_SHA256(input.bytes, UInt32(input.length), &hashValue)
        return NSData(bytes: hashValue, length: digestLength)
    }
    
    private  func getHexString(fromData data: NSData) -> String {
        var bytes = [UInt8](repeating: 0, count: data.length)
        data.getBytes(&bytes, length: data.length)
        
        var hexString = ""
        for byte in bytes {
            hexString += String(format:"%02x", UInt8(byte))
        }
        return hexString
    }
}
