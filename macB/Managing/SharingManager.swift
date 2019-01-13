//
//  SharingManager.swift
//  macB
//
//  Created by Denis Dobanda on 13.01.19.
//  Copyright © 2019 Denis Dobanda. All rights reserved.
//

import Foundation
import SwiftSocket

enum SharingManagerStatus {
    case notReady
    case ready
    case connected(String)
    case finished
    case failed(String)
}

class SharingManager: NSObject {
    
    // MARK: - Public API
    var delegate: SharingManagerDelegate?
    var occupiedURL: String?
    var port: Int32 = 8080
    var status: SharingManagerStatus = .notReady {didSet{broadcast()}}
    var sharingObjects: [SharingObject]?
    
    
    // MARK: - Public API
    private var server: TCPServer!
    private var listening = true
    
    func becomeAvailable() {
        DispatchQueue.global(qos: .background).async {
            self.startEngine()
        }
    }
    
    private func startEngine() {
        guard let ip = getWiFiAddress() else {status = .failed("No IP assigned");return}
        server = TCPServer(address: ip, port: port)
        occupiedURL = "\(ip):\(port)"
        
        DispatchQueue.main.async {
            self.status = .ready
        }
        listening = true
        switch server.listen() {
        case .success:
            while listening {
                if let client = server.accept() {
                    welcomeService(client: client)
                    DispatchQueue.main.async {
                        self.status = .connected(client.address)
                    }
                } else if listening {
                    DispatchQueue.main.async {
                        self.status = .failed("Accept error")
                    }
                }
            }
        case .failure(let error):
            DispatchQueue.main.async {
                self.status = .failed(error.localizedDescription)
            }
        }
    }
    
    private func welcomeService(client: TCPClient) {
        print("welcome")
        guard let b = client.read(3), String(bytes: b, encoding: .utf8) == "yes" else {return}
        if let objects = sharingObjects {
            let names = objects.map{$0.title}.joined(separator: "|")
            switch client.send(string: "\(names.count)") {
            case .success:
                if let b = client.read(3),
                    String(bytes: b, encoding: .utf8) == "yes" {
                    switch client.send(string: names) {
                    case .success:
                        print("Success all")
                    case .failure(let err):
                        print(err)
                    }
                }
            case .failure(let err):
                print(err)
            }
//            _ = client.send(string: "\(names.count)")
//            _ = client.send(string: names)
        } else {
            _ = client.send(string: "Not ready")
        }
    }

    
    func terminate() {
        listening = false
        server?.close()
        occupiedURL = nil
        status = .notReady
    }
    
    
    func broadcast() {
        delegate?.sharingManagerDidChangedStatus(to: status)
    }
    
}
