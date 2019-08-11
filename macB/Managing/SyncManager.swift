//
//  SyncManager.swift
//  macB
//
//  Created by Denis Dobanda on 27.04.19.
//  Copyright © 2019 Denis Dobanda. All rights reserved.
//

import Foundation

private func getTimestamp() -> Int {
    return Int(Date().timeIntervalSince1970)
}

typealias Closure = (String?) -> Void

// MARK: - Sync Object

struct SyncObject {
    
    var timestamp: Int? = nil
    var module: String
    var book: Int
    var chapter: Int
    var verse: Int
    var note: String?
    var color: String?
    
    func toJ() -> [String: Any] {
        var body: [String:Any] = [
            "module"    : module,   "book"    : book,
            "chapter"   : chapter,  "verse"   : verse,
        ]
        if note  != nil { body["note"]  = note!  }
        if color != nil { body["color"] = color! }
        return body
    }
    
    func toJAll() -> [String: Any] {
        var body = toJ()
        if note  == nil { body["note"]  = NSNull() }
        if color == nil { body["color"] = NSNull() }
        return body
    }
    
    static func parsing(_ data: Data?) -> SyncObject? {
        guard let data = data else { return nil }
        if let dictionary = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:Any] {
            return SyncObject.parsing(dictionary)
        }
        return nil
    }
    
    private static func parsing(_ dictionary: [String:Any] ) -> SyncObject? {
        if let module = dictionary["module"] as? String,
            let book = dictionary["book"] as? Int,
            let chapter = dictionary["chapter"] as? Int,
            let verse = dictionary["verse"] as? Int {
            let timestamp = dictionary["timestamp"] as? Int
            let note = dictionary["note"] as? String
            let color = dictionary["color"] as? String
            return SyncObject(
                timestamp: timestamp,
                module: module,
                book: book,
                chapter: chapter,
                verse: verse,
                note: note,
                color: color
            )
        }
        return nil
    }
    
    static func parsingArray(_ data: Data?) -> [SyncObject]? {
        guard let data = data else { return nil }
        if let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [Any] {
            var array = [SyncObject]()
            for dataObj in json {
                if let arrayObj = dataObj as? [String:Any], let obj = SyncObject.parsing(arrayObj) {
                    array.append(obj)
                }
            }
            return array
        }
        return nil
    }
}

// MARK: - ServerResponse

class ServerResponse: NSObject {
    
    /// Weather status is between 200 and 299
    var isGood: Bool {return 200...299 ~= status}
    var status: UInt
    var error: String?
    var data: Data?
    
    override init() {
        status = 0
        error = nil
        data = nil
    }
    
    static func tryToParse(_ data: Data?, _ response: URLResponse?, _ error: Error?) -> ServerResponse? {
        let res = ServerResponse()
        res.data = data
        if let httpResponse = response as? HTTPURLResponse {
            res.status = UInt(httpResponse.statusCode)
        }
        if error != nil {
            res.error = error!.localizedDescription
        } else if !res.isGood {
            if let jsonData = data,
                let json = try? JSONSerialization.jsonObject(with: jsonData, options: [.mutableContainers]),
                let array = json as? [String: Any] {
                if let message = array["message"] {
                    res.error = message as? String
                } else if let message = array["error"] {
                    res.error = message as? String
                } else if let message = array["err"] {
                    res.error = message as? String
                }
            }
        }
        return res
    }
    
}

// MARK: - SyncManager

class SyncManager: NSObject {
    
    static let shared = SyncManager()
    
    var syncedTimestamp: Int {
        get {
            return defaults.integer(forKey: "synced_timestamp")
        }
        set {
            defaults.set(newValue, forKey: "synced_timestamp")
        }
    }
    
    private var defaults: UserDefaults {return UserDefaults.standard }
    
    private var manager = ServerManager()
    
    func sync(objects: [SyncObject], completion: @escaping (String?, [SyncObject]) -> Void) {
        let data: [String:Any] = [
            "timestamp": syncedTimestamp,
            "new": objects.map {$0.toJAll()}
        ]
        do {
            try manager.executeRequest(url: .sync, method: .post, body: data, completion: { [weak self] response in
                guard let response = response else {completion("No usable response given", []);return}
                
                if !response.isGood {
                    completion(response.error ?? "Response status \(response.status)", []);return
                } else {
                    self?.syncedTimestamp = getTimestamp()
                    let sync = SyncObject.parsingArray(response.data)
                    completion(nil, sync ?? [])
                }
                
            })
        } catch {
            completion("Cannot interpter data to JSON", [])
        }
    }
}

// MARK: - ServerStorage

class ServerStorage: NSObject {
    
    struct StorageIndex {
        var module: String
        var book: Int
        var chapter: Int
        var verse: Int
    }
    
    static fileprivate var manager = ServerManager()
    
    static func addRecord(object: SyncObject, completion: @escaping Closure) {
        executeStorageRequest(method: .post, object: object, completion: completion)
    }
    
    static func editRecord(object: SyncObject, completion: @escaping Closure) {
        executeStorageRequest(method: .put, object: object, completion: completion)
    }
    
    static func deleteRecord(object: SyncObject, completion: @escaping Closure) {
        executeStorageRequest(method: .delete, object: object, completion: completion)
    }
    
    static private func executeStorageRequest(method: ServerManager.HTTPMethods, object: SyncObject, completion: @escaping Closure) {
        guard object.note != nil || object.color != nil else {completion("No note or color provided");return}
        do {
            try manager.executeRequest(url: .storage, method: method, body: object.toJ()) { response in
                
                guard let response = response else {completion("No usable response given");return}
                
                if !response.isGood {
                    completion(response.error ?? "Response status \(response.status)")
                } else {
                    completion(nil)
                }
            }
        } catch {
            completion("Cannot create JSON...")
        }
    }
}

// MARK: - UserManager

class UserManager: NSObject {
    
    var userMail: String? {
        get {
            return defaults.string(forKey: "user_mail")
        }
        set {
            defaults.set(newValue, forKey: "user_mail")
        }
    }
    
    var isLoggedIn: Bool {
        return serverManager.token != nil
    }
    
    private var serverManager = ServerManager()
    private var defaults: UserDefaults {return UserDefaults.standard }
    
    private var uuid: String {
        return defaults.string(forKey: "UUID")!
    }
    
    override init() {
        super.init()
        if defaults.string(forKey: "UUID") == nil {
            defaults.set(UUID().uuidString, forKey: "UUID")
        }
    }
    
    func login(with mail: String, and password: String, completion: @escaping Closure) {
        let credantials = ["mail": mail,"passHash": password.SHA256(), "uuid": uuid]
        runPostRequest(url: .login, body: credantials, completion: completion)
    }
    
    func register(with mail: String, and password: String, completion: @escaping Closure) {
        let credantials = ["mail": mail,"passHash": password.SHA256(), "uuid": uuid]
        runPostRequest(url: .user, body: credantials, completion: completion)
    }
    
    /// Runs POST request to server on a given URL with a given BODY.
    /// Use for login or registration. Or in any case in which response contains 'token'.
    /// In case of successfully arrived token, it will be stored in UserDefaults
    ///
    /// - Parameters:
    ///   - url: ServerManager.Urls case - a needed URL
    ///   - body: a body to send of type Any
    ///   - completion: escaping function of optional error. No error - success
    private func runPostRequest(url: ServerManager.Urls, body: Any, completion: @escaping Closure) {
        do {
            try serverManager.executeRequest(url: url, method: .post, body: body) { (response) in
                
                guard let response = response else {completion("No usable response given");return}
                
                if !response.isGood {
                    completion(response.error ?? "Response status \(response.status)");return
                }
                
                if let data = response.data,
                    let jsonData = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers),
                    let json = jsonData as? [String:AnyObject] {
                    if let arrived = json["token"] as? String {
                        self.serverManager.token = arrived
                        completion(nil);return
                    } else {
                        print(json)
                        completion("Login unsuccessful")
                    }
                }
            }
        } catch {
            completion("Cannot interpolate data as JSON: \(error.localizedDescription)")
        }
    }
    
    func editUser(mail: String?, password: String?, completion: @escaping Closure) {
        var credentials = [String:Any]()
        if mail != nil {credentials["mail"] = mail!}
        if password != nil {credentials["passHash"] = password!.SHA256()}
        do {
            try serverManager.executeRequest(url: .user, method: .put, body: credentials) { (response) in
                guard let response = response else {completion("No usable response given");return}
                
                if !response.isGood {
                    completion(response.error ?? "Response status \(response.status)");return
                } else {
                    completion(nil)
                }
            }
        } catch {
            completion("Cannot execute request: JSON Serialization failed")
        }
    }
    
    func logout() -> Bool {
        serverManager.token = nil
        return true
    }
    
    func removeUser(completion: @escaping Closure) {
        do {
            try serverManager.executeRequest(url: .user, method: .delete, body: nil) { response in
                
                guard let response = response else {completion("No usable response given");return}
                
                if !response.isGood {
                    completion(response.error ?? "Response status \(response.status)");return
                } else {
                    completion(nil)
                    self.userMail = nil
                    self.serverManager.token = nil
                }
            }
        } catch {
            completion("Cannot interpolate data as JSON: \(error.localizedDescription)")
        }
    }
}

// MARK: ServerManager - Core

/// ServerManager provides convenient access to the needed server.
/// Has a token-including-in-header ability.
private class ServerManager: NSObject {
    
    /// Enum describing a server's API
    ///
    /// - login: a login url
    /// - user: a users url
    /// - sync: a sync url
    enum Urls: String {
        case login = "http://localhost:3000/api/login"
        case user = "http://localhost:3000/api/users"
        case storage = "http://localhost:3000/api/stored"
        case sync = "http://localhost:3000/api/sync"
    }
    
    /// HTTP Methods all-in-one
    ///
    /// - get: GET
    /// - post: POST
    /// - put: PUT
    /// - delete: DELETE
    enum HTTPMethods: String {
        case get = "get"
        case post = "post"
        case put = "put"
        case delete = "delete"
    }
    
    /// UserDefaults instance for convenice
    private var defaults: UserDefaults {return UserDefaults.standard }
    
    /// Reading/Writing a 'token' string into the UserDefaults
    var token: String? {
        get {
            return defaults.string(forKey: "login_token")
        }
        set {
            defaults.set(newValue, forKey: "login_token")
        }
    }
    
    /// Executs request to a given URL with a given method and body.
    /// Runs asyncronously and executs a completion function.
    ///
    /// - Parameters:
    ///   - url: a Urls case
    ///   - method: HTTPMethod case
    ///   - body: Any? - needs to be serializeable, or throws an error
    ///   - completion: a completion handler for URLSession.dataTask()
    /// - Throws: JSON Serialization error if body is not serializeable
    @available(*, deprecated)
    func executeRequest(
        url: Urls,
        method: HTTPMethods,
        body: Any?,
        completion: @escaping (Data?, URLResponse?, Error?) -> Void) throws
    {
        URLSession.shared.dataTask(
            with: try getRequest(url, method, body),
            completionHandler: completion
            ).resume()
    }
    
    /// Executs request to a given URL with a given method and body.
    /// Runs asyncronously and executs a completion function.
    ///
    /// - Parameters:
    ///   - url: a Urls case
    ///   - method: HTTPMethod case
    ///   - body: Any? - needs to be serializeable, or throws an error
    ///   - completion: a completion handler for URLSession.dataTask()
    /// - Throws: JSON Serialization error if body is not serializeable
    func executeRequest(
        url: Urls,
        method: HTTPMethods,
        body: Any?,
        completion: @escaping (ServerResponse?) -> Void) throws
    {
        URLSession.shared.dataTask(
            with: try getRequest(url, method, body),
            completionHandler: {completion(ServerResponse.tryToParse($0, $1, $2))}
            ).resume()
    }
    
    /// Creates a request with a given parameters
    ///
    /// - Parameters:
    ///   - url: a Urls case
    ///   - method: a HTTPMethod case
    ///   - body: Any? - needs to be serializeable, or throws an error
    /// - Returns: a URLRequest
    /// - Throws: a JSONSerialization error
    private func getRequest(_ url: Urls, _ method: HTTPMethods, _ body: Any?) throws -> URLRequest {
        var req = URLRequest(url: URL(string: url.rawValue)!)
        req.httpMethod = method.rawValue
        if let tok = token {
            req.setValue("Bearer \(tok)", forHTTPHeaderField: "Authorization")
        }
        if let b = body {
            do {
                req.httpBody = try JSONSerialization.data(withJSONObject: b, options: [])
            } catch {
                throw error
            }
        }
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        return req
    }
    
}
