//
//  SharingManager.swift
//  macB
//
//  Created by Denis Dobanda on 13.01.19.
//  Copyright © 2019 Denis Dobanda. All rights reserved.
//

import Foundation


class SharingManager: NSObject {
    
    var delegate: BonjourManagerDelegate?
    var shared: [String:String]? {didSet{reteach()}}
    
    private var selectedKeys: [String]?
    
    private var type = "_thedenizbiblesync._tcp."
    
    private var currentStatus: BonjourClientState?
    
    private var service: NetService?
    private var input: InputStream?
    private var output: OutputStream?
    
    private var syncThread: Thread?
    private var syncConfirmationFlag = false
    private var chunkSize = 4096
    
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
    
    private func resolveConnection() {
        input?.delegate = self
        output?.delegate = self
        
        input?.schedule(in: RunLoop.current, forMode: .default)
        output?.schedule(in: RunLoop.current, forMode: .default)
        
        input?.open()
        output?.open()
        
        dealWithClientAccordingTo(status: .newborn)
    }
    
    private func serviceTerminate() {
//        print("service terminated")
        syncThread?.cancel()
        syncThread = nil
        input?.close()
        output?.close()
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
            send(greeting: .firstMeet)
        case .alive:
            send(shared: shared ?? [:])
        case .busy:
            syncThread = Thread(target: self, selector: #selector(sendSelectedKeys), object: nil)
            syncThread!.start()
//            sendSelectedKeys()
        case .finished:
            send(greeting: .finished)
        case .dead:
            currentStatus = nil
        default:
            break
        }
    }
    
    private func parse(data: Data) {
//        print("reading")
        let s = String(data: data, encoding: .utf8)
        delegate?.bonjourDidRead(message: s)
        guard let message = s, let status = currentStatus else {
            if currentStatus != nil, (currentStatus == .ready || currentStatus == .waiting) {
                parseSelected(data)
            }
            return
        }
        if message == BonjourClientGreetingOption.bye.rawValue {
            dealWithClientAccordingTo(status: .finished)
//            print("Finished")
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
        case .busy:
            if message == BonjourClientGreetingOption.confirm.rawValue {
                syncConfirmationFlag = true
            }
        case .finished:
            if message == BonjourClientGreetingOption.confirm.rawValue {
                dealWithClientAccordingTo(status: .waiting)
            }
        default:break
        }
    }
    
    private func parseSelected(_ data: Data) {
        if let unarchived = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? [String] {
            selectedKeys = unarchived
            dealWithClientAccordingTo(status: .busy)
        } else {
            print("Data cannot be unarchived")
        }
    }
    
    private func reteach() {
        if currentStatus != nil {
            dealWithClientAccordingTo(status: .newborn)
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

extension SharingManager: StreamDelegate {
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        switch (eventCode) {
        case Stream.Event.openCompleted:
            if(aStream == output) {
                                print("output:OutPutStream opened")
            } else {
                                print("Input = openCompleted")
            }
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
            serviceTerminate()
        case Stream.Event.hasSpaceAvailable:break
//            if(aStream === output) {
//                                print("output:hasSpaceAvailable\n")
//            } else {
//                                print("Input = hasSpaceAvailable\n")
//            }
        case Stream.Event.hasBytesAvailable:
            if(aStream === output) {
//                                print("output:hasBytesAvailable\n")
            } else if aStream === input {
//                                print("Input:hasBytesAvailable\n")
                var buffer = [UInt8](repeating: 0, count: chunkSize)
                
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
    func send(message: String) {
        let p = ([UInt8])(message.utf8)
        output?.write(p, maxLength: p.count)
    }
    
    private func send(greeting: BonjourClientGreetingOption) {
        send(message: greeting.rawValue)
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

extension SharingManager {
    @objc private func sendSelectedKeys() {
        guard let selected = selectedKeys else {dealWithClientAccordingTo(status: .deprecated);return}
        for key in selected {
            if key.matches(SharingRegex.strong) {
                sendStrongs(type: key.capturedGroups(withRegex: SharingRegex.strong)![0])
            } else if key.matches(SharingRegex.module) {
                sendModule(key: key.capturedGroups(withRegex: SharingRegex.module)![0])
            } else if key.matches(SharingRegex.spirit) {
//                sendSpirit(name: key.capturedGroups(withRegex: SharingRegex.spirit)![0])
            }
        }
        dealWithClientAccordingTo(status: .finished)
    }
    
    private func sendStrongs(type: String) {
        let context = AppDelegate.context
        if let strongs = try? Strong.get(by: type, from: context) {
            print("Sending strong \(type)")
            var shared = [SyncStrong]()
            for s in strongs {
                shared.append(SyncStrong(number: Int(s.number), meaning: s.meaning, original: s.original))
            }
//            let shared = strongs.map {SyncStrong.init(number: Int($0.number), meaning: $0.meaning, original: $0.original) }
            do {
                let data = try NSKeyedArchiver.archivedData(withRootObject: shared, requiringSecureCoding: true)
                let chunks = data.chunking(chunkSize)
                let message = SharingRegex.sync(SharingRegex.strong(type), counting: chunks.count - 1, last: chunks.last!.count )
//                print(message)
//                print("real number: \(chunks.count) with last \(chunks.last!.count)")
                send(message: message)
                while(!syncConfirmationFlag) {sleep(1)}
                syncConfirmationFlag = false
//                print("------------got confirm")
                let count = chunks.count
                for i in 0..<count {
                    send(data: chunks[i])
//                    if i % 35 == 0 {usleep(1000)}
                    usleep(1000)
//                    print("Sent \(i) from \(count)")
                }
                while(!syncConfirmationFlag) {sleep(1)}
                syncConfirmationFlag = false
//                print("------------got confirm one more time")
            } catch {
                print(error)
            }
        }
    }
    
    private func sendModule(key: String) {
        let context = AppDelegate.context
        if let m = try? Module.get(by: key, from: context), let module = m {
            print("Sending Module \(key)")
            let shared = SyncModule(key: key, name: module.name, local: module.local)
            for book in module.books!.array as! [Book] {
                let syncBook = SyncBook(number: Int(book.number), name: book.name)
                for chapter in book.chapters!.array as! [Chapter] {
                    let syncChapter = SyncChapter(number: Int(chapter.number))
                    for verse in chapter.verses!.array as! [Verse] {
                        syncChapter.verses.append(SyncVerse(number: Int(verse.number), text: verse.text ?? ""))
                    }
                    syncBook.chapters.append(syncChapter)
                }
                shared.books.append(syncBook)
            }
            //            let shared = strongs.map {SyncStrong.init(number: Int($0.number), meaning: $0.meaning, original: $0.original) }
            do {
                let data = try NSKeyedArchiver.archivedData(withRootObject: shared, requiringSecureCoding: true)
                let chunks = data.chunking(chunkSize)
                let message = SharingRegex.sync(SharingRegex.module(key), counting: chunks.count - 1, last: chunks.last!.count )
//                print(message)
//                print("real number: \(chunks.count) with last \(chunks.last!.count)")
                send(message: message)
                while(!syncConfirmationFlag) {sleep(1)}
                syncConfirmationFlag = false
//                print("------------got confirm")
                let count = chunks.count
                for i in 0..<count {
                    send(data: chunks[i])
                    //                    if i % 35 == 0 {usleep(1000)}
                    usleep(1000)
                    //                    print("Sent \(i) from \(count)")
                }
                while(!syncConfirmationFlag) {sleep(1)}
                syncConfirmationFlag = false
//                print("------------got confirm one more time")
            } catch {
                print(error)
            }
        }
    }
}
