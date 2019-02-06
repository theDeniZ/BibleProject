//
//  DownloadManager.swift
//  SplitB
//
//  Created by Denis Dobanda on 25.10.18.
//  Copyright © 2018 Denis Dobanda. All rights reserved.
//

import UIKit
import CoreData

class DownloadManager {

    var context: NSManagedObjectContext!
    private var serverUrl = "http://getbible.net/json?v="
    
    init(in context: NSManagedObjectContext) {
        self.context = context
    }
    
    func removeAsync(_ module: ModuleOffline, completition: ((Bool, String) -> Void)? = nil) {
        if let mod = try? Module.get(by: module.key, from: context), let m = mod {
            context.delete(m)
            try? context.save()
            completition?(true, "")
        } else {
            completition?(false, "No such object")
        }
    }
    
    func downloadAsync(_ module: ModuleOffline, completition: ((Bool, String) -> Void)? = nil) {
        guard let url = URL(string: serverUrl + module.key)
        else {
            completition?(false, "URL error")
            return
        }
        
        let urlRequest = URLRequest(url: url)
        
        // Make request
        let session = URLSession.shared
        let task = session.dataTask(with: urlRequest, completionHandler: { [weak self]
            (data, response, error) in
            // handle response to request
            // check for error
            guard error == nil else {
                completition?(false, error.debugDescription)
                return
            }
            // make sure we got data in the response
            guard let responseData = data else {
                completition?(false, "Error: did not receive data")
                return
            }
            var strData = String(data: responseData, encoding: .utf8)
            strData!.removeFirst()
            strData!.removeLast()
            strData!.removeLast()
            
            let jsonData = strData?.data(using: .utf8)
            // parse the result as JSON
            // then create a Todo from the JSON
            do {
                if let json = try JSONSerialization.jsonObject(with: jsonData!, options: []) as? [String: Any],
                    let cont = self?.context,
                    let _ = Module.create(from: json, with: module.name, in: cont)
                {
                    try? cont.save()
                    completition?(true, "")
                } else {
                    completition?(false, "JSON parsing failed to write")
                }
            } catch {
                completition?(false, "JSON parsing failed")
                return
            }
        })
        task.resume()
    }
    
}
