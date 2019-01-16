//
//  SharingManager.swift
//  macB
//
//  Created by Denis Dobanda on 13.01.19.
//  Copyright © 2019 Denis Dobanda. All rights reserved.
//

import Foundation

enum BonjourClientState {
    case newborn
    case alive
    case wise
    case ready
    case busy
    case deprecated
    case finished
    case dead
}

enum BonjourClientGreetingOption: String {
    case firstMeet = "hi, ready to get to know me?"
    case confirm = "yes"
    case ready = "ready to receive"
    case bye = "bye"
//    case
}

class SharingManager: NSObject {
    
    var delegate: BonjourManagerDelegate?
    var shared: [String:String]? {didSet{reteach()}}
    
    private var type = "_thedenizbiblesync._tcp."
    
    private var currentStatus: BonjourClientState?
    
    private var service: NetService?
    private var input: InputStream?
    private var output: OutputStream?
    private var occupiedRunLoop: RunLoop?
    private var operationInQueue: (() -> ())?
    
    override init() {
        super.init()
    }
    
    func startEngine() {
        service = NetService(domain: "", type: type, name: "")
        service?.delegate = self
        service?.publish(options: [.listenForConnections])
    }
    
    func stopEngine() {
        serviceTerminate()
        service?.stop()
    }
//
//    private func serviceActivate() {
//        guard let service = service else {return}
//        service.getInputStream(&input, outputStream: &output)
//        resolveConnection()
//    }
    
    private func resolveConnection() {
        input?.delegate = self
        output?.delegate = self
        
        occupiedRunLoop = RunLoop.current
        input?.schedule(in: RunLoop.current, forMode: .default)
        output?.schedule(in: RunLoop.current, forMode: .default)
        
        input?.open()
        output?.open()
        
        operationInQueue = {self.dealWithClientAccordingTo(status: .newborn)}
    }
    
    private func serviceTerminate() {
        if let loop = occupiedRunLoop {
            print("service terminated")
            input?.close()
            output?.close()
            input?.remove(from: loop, forMode: .default)
            output?.remove(from: loop, forMode: .default)
            input = nil
            output = nil
            occupiedRunLoop = nil
        }
    }
    
    private func reloadClientData() {
        if currentStatus != nil {
            dealWithClientAccordingTo(status: .deprecated)
        }
    }
    
    private func dealWithClientAccordingTo(status: BonjourClientState) {
        currentStatus = status
        switch status {
        case .newborn:
            print("sending greetings")
            send(greeting: .firstMeet)
            print("sent greetings")
        case .alive:
            send(shared: shared ?? [:])
        case .finished:
            currentStatus = nil
        case .dead:
            currentStatus = nil
        default:
            break
        }
    }
    
    private func parse(data: Data) {
        print("reading")
        let s = String(data: data, encoding: .utf8)
        delegate?.bonjourDidRead(message: s)
        guard let message = s, let status = currentStatus else {return}
        if message == BonjourClientGreetingOption.bye.rawValue {
            dealWithClientAccordingTo(status: .finished)
            print("Finished")
            return
        }
        switch status {
        case .newborn:
            if message == BonjourClientGreetingOption.confirm.rawValue {
                dealWithClientAccordingTo(status: .alive)
            }
        case .alive:
            if message == BonjourClientGreetingOption.confirm.rawValue {
                dealWithClientAccordingTo(status: .wise)
            }
        case .wise:
            if message == BonjourClientGreetingOption.ready.rawValue {
                dealWithClientAccordingTo(status: .ready)
            }
        default:break
        }
    }
    
    private func reteach() {
        if currentStatus != nil {
            dealWithClientAccordingTo(status: .newborn)
        }
    }
    
    private func streamWasOpened(_ stream: Stream) {
        if stream == output {
            operationInQueue?()
            operationInQueue = nil
        }
    }
    
}

extension SharingManager: NetServiceDelegate {
    func netServiceDidPublish(_ sender: NetService) {
        delegate?.bonjourServiceUpdated(to: "Published at \(sender.hostName ?? "?host?"):\(sender.port)")
    }
    
    func netServiceDidStop(_ sender: NetService) {
        delegate?.bonjourServiceUpdated(to: "Service stopped")
    }
    
    func netServiceWillPublish(_ sender: NetService) {
        
    }
    
    func netServiceWillResolve(_ sender: NetService) {
        print("Service did resolve")
    }
    
    func netServiceDidResolveAddress(_ sender: NetService) {
        delegate?.bonjourServiceUpdated(to: "Service resolved address: \(sender.hostName ?? "NoHostName!"):\(sender.port)")
    }
    
    func netService(_ sender: NetService, didUpdateTXTRecord data: Data) {
        print("Service did updateTXTRecord")
    }
    
    func netService(_ sender: NetService, didNotPublish errorDict: [String : NSNumber]) {
        delegate?.bonjourServiceUpdated(to: "Service didNotPublish")
    }
    
    func netService(_ sender: NetService, didNotResolve errorDict: [String : NSNumber]) {
        delegate?.bonjourServiceUpdated(to: "Service didNotResolve: \(errorDict)")
    }
    
    func netService(_ sender: NetService, didAcceptConnectionWith inputStream: InputStream, outputStream: OutputStream) {
        delegate?.bonjourDidChanged(isConnected: true, to: sender.hostName, at: sender.port)
        serviceTerminate()
        currentStatus = nil
        input = inputStream
        output = outputStream
        resolveConnection()
        print("connection established")
    }
}

//extension SharingManager: BonjourServiceDelegate {
//    func updateConnectionStatus(isConnected: Bool) {
//        delegate?.bonjourDidChanged(isConnected: isConnected, to: nil, at: nil)
//        print("-->DidUpdateTo \(isConnected)")
////        dealWithClientAccordingTo(status: isConnected ? (currentStatus ?? .newborn) : .dead)
//        if isConnected {serviceActivate()} else {serviceTerminate()}
//    }
//
//    func didConnect(to host: String!, port: UInt16) {
//        delegate?.bonjourDidChanged(isConnected: bonjour.isConnected, to: host, at: Int(port))
//        print("-->DidConnect")
//    }
//
//    func didAcceptNewSocket() {
//        delegate?.bonjourDidChanged(isConnected: bonjour.isConnected, to: nil, at: nil)
////        dealWithClientAccordingTo(status: .newborn)
//        print("-->DidConnectSocket")
//    }
//
//    func socketDidDisconnect() {
//        delegate?.bonjourDidChanged(isConnected: bonjour.isConnected, to: nil, at: nil)
//        print("-->DidDisconnectSocket")
//    }
//
//    func didWriteData(tag: Int) {
//        delegate?.bonjourDidWrite()
//    }
//
//    func didRead(data: Data, tag: Int) {
//        print("reading from the hell knows where")
//        parse(data: data)
//    }
//
//    func netServiceDidPublish(_ netService: NetService) {
//        delegate?.bonjourServiceUpdated(to:
//            "Did publish '\(netService.name)' at \(netService.hostName ?? ".local"):\(netService.port)"
//        )
//        self.service = netService
//    }
//
//    func netServiceDidNotPublish(_ netService: NetService) {
//        delegate?.bonjourServiceUpdated(to:
//            "Did not publish '\(netService.name)' at \(netService.hostName ?? ".local"):\(netService.port)"
//        )
//    }
//
//
//}

extension SharingManager: StreamDelegate {
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        switch (eventCode) {
        case Stream.Event.openCompleted:
            if(aStream == output) {
                                print("output:OutPutStream opened")
            } else {
                                print("Input = openCompleted")
            }
            streamWasOpened(aStream)
        case Stream.Event.errorOccurred:
            if(aStream === output) {
                                print("output:Error Occurred\n")
            } else {
                                print("Input : Error Occurred\n")
            }
            serviceTerminate()
        case Stream.Event.endEncountered:
            if(aStream === output) {
                                print("output:endEncountered\n")
            } else {
                                print("Input = endEncountered\n")
            }
        case Stream.Event.hasSpaceAvailable:
            if(aStream === output) {
                                print("output:hasSpaceAvailable\n")
            } else {
                                print("Input = hasSpaceAvailable\n")
            }
        case Stream.Event.hasBytesAvailable:
            if(aStream === output) {
                                print("output:hasBytesAvailable\n")
            } else if aStream === input {
                                print("Input:hasBytesAvailable\n")
                var buffer = [UInt8](repeating: 0, count: 4096)
                
                while input != nil, self.input!.hasBytesAvailable {
                    let len = input!.read(&buffer, maxLength: buffer.count)
                    // If read bytes are less than 0 -> error
                    if len < 0 {
                        let error = self.input!.streamError
                                                print("Input stream has less than 0 bytes\(error!)")
                        //closeNetworkCommunication()
//                        serviceTerminate()
                    }
                        // If read bytes equal 0 -> close connection
                    else if len == 0 {
                                                print("Input stream has 0 bytes")
                        // closeNetworkCommunication()
//                        serviceTerminate()
                    }
                    if(len > 0) {
                        parse(data: Data(bytes: buffer[0..<len]))
                        //here it will check it out for the data sending from the server if it is greater than 0 means if there is a data means it will write
                        //                        let messageFromServer = NSString(bytes: &buffer, length: buffer.count, encoding: String.Encoding.utf8.rawValue)
                        //                        if messageFromServer == nil {
                        //                            print("Network has been closed")
                        //                            // v1.closeNetworkCommunication()
                        //                        } else {
                        //                            print("MessageFromServer = \(messageFromServer!)")
                        //                        }
                    }
                }
            }
            
        default:
            print("default block")
        }
    }
}

extension SharingManager {
    func write(message: String) {
        let p = ([UInt8])(message.utf8)
        output?.write(p, maxLength: p.count)
    }
    
    private func send(greeting: BonjourClientGreetingOption) {
        write(message: greeting.rawValue)
    }
    
    private func send(data: Data) {
        let p = [UInt8](data)
        output?.write(p, maxLength: p.count)
    }
    
    private func send(shared: [String:String]) {
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: shared, requiringSecureCoding: true)
            send(data: data)
        } catch  {
            print("Sending shared data error: " + error.localizedDescription)
        }
    }
}
