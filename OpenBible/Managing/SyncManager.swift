//
//  SyncManager.swift
//  OpenBible
//
//  Created by Denis Dobanda on 15.01.19.
//  Copyright © 2019 Denis Dobanda. All rights reserved.
//

import Foundation

class SyncManager: NSObject {
    
    var service: NetService?
    var delegate: SyncManagerDelegate?
    
    var sharedObjects: [String:String]?
    var selectedObjects: [Bool]?
    
    private var input: InputStream?
    private var output: OutputStream?
    private var state: BonjourServerState?
    private var syncState: SyncingState = .none
    
    private var coreSyncManager = CoreSyncManager()
    
    private var overallCount = 0
    private var processedCount = 0
    
    private var isInDataSync = false
    private var currentChunksCount = 0
    private var receivedChunksCount = 0
    private var lastSize = 0
    private let chunkSize = 4096
    
    private var currentIndex = 0
    
    func initialize() {
        service!.getInputStream(&input, outputStream: &output)
        input?.delegate = self
        output?.delegate = self
        input?.schedule(in: RunLoop.current, forMode: .default)
        output?.schedule(in: RunLoop.current, forMode: .default)
        state = .greeting
        input?.open()
        output?.open()
    }
    
    func closeNetworkCommunication(_ sendingByeMessage: Bool = true) {
        guard input != nil, output != nil else {return}
        print("closing")
        if sendingByeMessage {send(greeting: .bye)} else {delegate?.syncManagerDidTerminate()}
        input?.delegate = nil
        output?.delegate = nil
        input?.close()
        output?.close()
        input = nil
        output = nil
    }
    
    private func parse(data: Data) {
        guard var state = state else {return}
        if let message = String(data: data, encoding: .utf8),
            message == BonjourClientGreetingOption.firstMeet.rawValue {
            self.state = .greeting
            state = .greeting
        }
        switch state {
        case .greeting:
//            print("greeted")
            if let string = String(data: data, encoding: .utf8),
                string == BonjourClientGreetingOption.firstMeet.rawValue {
                send(greeting: .confirm)
                self.state = .teaching
            } else {
                print("cannot interptret")
                send(greeting: .bye)
            }
        case .teaching:
//            print("teaching")
            if let dict = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? [String:String] {
                sharedObjects = dict
                selectedObjects = [Bool](repeating: true, count: dict?.count ?? 0)
                delegate?.syncManagerDidGetUpdate()
                send(greeting: .confirm)
                self.state = .waiting
            } else {
                print("cannot interptret")
                send(greeting: .bye)
            }
        case .inSync:
            parseSync(data: data)
        default: break
        }
    }
    
    func sync() {
        guard let dict = sharedObjects, let select = selectedObjects, dict.count == select.count else {return}
        send(greeting: .ready)
        state = .inSync
        syncState = .none
        isInDataSync = false
        let keys = Array(dict.keys)
        var selectedKeys = [String]()
        for i in 0..<keys.count {
            if select[i] {
                selectedKeys.append(keys[i])
            }
        }
        send(keys: selectedKeys)
    }
    
    private func parseSync(data: Data) {
        if data.count < 100, let message = String(data: data, encoding: .utf8) {
//            print("received '\(message)'")
            if message == BonjourClientGreetingOption.finished.rawValue {
                delegate?.syncManagerDidFinished()
                send(greeting: .confirm)
                state = .waiting
                syncState = .none
                resetProgress()
                return
            }
        }
        switch syncState {
        case .none:
            if let message = String(data: data, encoding: .utf8) {
                if message.matches(BonjourClientGreetingOption.regexForSync.rawValue) {
                    let match = message.capturedGroups(withRegex: BonjourClientGreetingOption.regexForSync.rawValue)!
                    let syncType = match[0]
                    currentChunksCount = Int(match[1])!
                    lastSize = Int(match[2])!
                    overallCount = currentChunksCount + 1
                    if syncType.matches(SharingRegex.strong) {
                        syncState = .strongs(syncType.capturedGroups(withRegex: SharingRegex.strong)![0])
                    } else if syncType.matches(SharingRegex.module) {
                        syncState = .module(syncType.capturedGroups(withRegex: SharingRegex.module)![0])
                    }
                    let keys = Array(sharedObjects!.keys)
                    var index = 0
                    while index < keys.count, keys[index] != syncType {index += 1}
                    currentIndex = index
                    isInDataSync = true
                    receivedChunksCount = 0
                    delegate?.syncManagerDidStartSync(at: index)
                    send(greeting: .confirm)
                }
                //else some other identifier
            }
        case .strongs(let strongType):
            coreSyncManager.add(data)
            delegate?.syncManagerDidSync(getNextProgress())
            
            if !isInDataSync {
                send(greeting: .confirm)
                resetProgress()
                delegate?.syncManagerDidEndSync(at: currentIndex, with: coreSyncManager.parseStrongs(strongType))
                currentChunksCount = 0
                lastSize = 0
                syncState = .none
            }
        case .module(_):
            coreSyncManager.add(data)
            delegate?.syncManagerDidSync(getNextProgress())
            
            if !isInDataSync {
                send(greeting: .confirm)
                resetProgress()
                delegate?.syncManagerDidEndSync(at: currentIndex, with: coreSyncManager.parseModule())
                currentChunksCount = 0
                lastSize = 0
                syncState = .none
            }
            
        default:
            break
        }
        
    }
}

extension SyncManager: StreamDelegate {
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        //        print("EventCode = \(eventCode)")
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
        case Stream.Event.endEncountered:
            if(aStream === output) {
                print("output:endEncountered\n")
            } else {
                print("Input = endEncountered\n")
            }
            closeNetworkCommunication(false)
        case Stream.Event.hasSpaceAvailable:
            if(aStream === output) {
                //                print("output:hasSpaceAvailable\n")
            } else {
                //                print("Input = hasSpaceAvailable\n")
            }
        case Stream.Event.hasBytesAvailable:
            if(aStream === output) {
//                print("output:hasBytesAvailable\n")
            } else if aStream === input {
//                print("Input:hasBytesAvailable\n")
                while (self.input!.hasBytesAvailable) {
//                    print("I'm is \(isInDataSync ? "" : "not ")in Data Sync")
                    if !isInDataSync {
                        var buffer = [UInt8](repeating: 0, count: chunkSize)
                        let len = input!.read(&buffer, maxLength: buffer.count)
                        // If read bytes are less than 0 -> error
                        if len < 0 {
                            let error = self.input!.streamError
                            print("Input stream has less than 0 bytes\(error!)")
                            //closeNetworkCommunication()
                        }
                            // If read bytes equal 0 -> close connection
                        else if len == 0 {
                            print("Input stream has 0 bytes")
                            // closeNetworkCommunication()
                        }
                        if(len > 0) {
                            parse(data: Data(bytes: buffer[0..<len]))
                        }
                    } else {
                        if receivedChunksCount < currentChunksCount {
                            var buffer = [UInt8](repeating: 0, count: chunkSize)
                            let len = input!.read(&buffer, maxLength: buffer.count)
                            if len != chunkSize {
                                print("Error reading data.. Read \(len) instead of \(chunkSize)")
                            }
                            if lastSize == 0, receivedChunksCount == currentChunksCount {isInDataSync = false}
                            parse(data: Data(bytes: buffer[0..<len]))
                            receivedChunksCount += 1
                        } else {
                            var buffer = [UInt8](repeating: 0, count: lastSize)
                            let len = input!.read(&buffer, maxLength: buffer.count)
                            isInDataSync = false
                            if len != lastSize {
                                print("Error reading last data: Not sufficient lenght. Expected \(lastSize), arrived \(len)")
                            }
                            parse(data: Data(bytes: buffer[0..<len]))
                            
                        }
                    }
                }
            }
            
        default:
            print("default block")
        }
    }
}

extension SyncManager {
    private func send(message: String) {
        DispatchQueue.global(qos: .userInteractive).async {
            let p = ([UInt8])(message.utf8)
            self.output?.write(p, maxLength: p.count)
        }
    }
    
    private func send(greeting: BonjourClientGreetingOption) {
        send(message: greeting.rawValue)
    }
    
    private func send(data: Data) {
        let p = [UInt8](data)
        output?.write(p, maxLength: p.count)
    }
    
    private func send(keys: [String]) {
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: keys, requiringSecureCoding: true)
            send(data: data)
        } catch  {
            print("Sending shared data error: " + error.localizedDescription)
        }
    }
}

extension SyncManager {
    private func getNextProgress() -> Float {
        if overallCount != 0 {
            processedCount += 1
            return Float(processedCount) / Float(overallCount)
        }
        return 0.0
    }
    
    private func resetProgress() {
        overallCount = 0
        processedCount = 0
    }
}
