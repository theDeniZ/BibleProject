//
//  DownloadService.swift
//  OpenBible
//
//  Created by Denis Dobanda on 24.03.19.
//  Copyright © 2019 Denis Dobanda. All rights reserved.
//

import Foundation

class DownloadService: NSObject {
    
    var modules = [DownloadModel]()
    var strongs = [DownloadModel]()
    var spirit = [DownloadModel]()
    var allExists: Bool = false
    
    private lazy var manager = AppDelegate.shared.consistentManager
    
    func download(_ file: String, completition: @escaping (Bool) -> ()) {
        manager?.download(file: file, completition: completition)
    }
    
    func remove(_ file: String, completition: @escaping () -> ()) {
        manager?.remove(file, completition: completition)
        allExists = false
    }
    
    func readFromServer(completition: @escaping () -> ()) {
        guard modules.count == 0, strongs.count == 0, spirit.count == 0 else {return}
        let context = AppDelegate.context
        guard let url = URL(string: AppDelegate.downloadServerURL) else {return}
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil {
                print(error!)
            }
            var allExist = true
            if data != nil,
                let json = try? JSONSerialization.jsonObject(
                    with: data!, options: .allowFragments
                    ) as? [[String:String]],
                let array = json {
                for file in array {
                    if let name = file["name"],
                        let size = file["size"],
                        let path = file["path"],
                        let regex = file["key"] {
                        if let key = SharingRegex.parseModule(regex) {
                            let exist = Module.exists(key: key, in: context)
                            allExist = allExist && exist
                            self.modules.append(DownloadModel(size: size, name: name, loaded: exist, loading: false, path: path))
                        } else if let key = SharingRegex.parseStrong(regex) {
                            let exist = (try? Strong.exists(key, in: context)) ?? false
                            allExist = allExist && exist
                            self.strongs.append(DownloadModel(size: size, name: name, loaded: exist, loading: false, path: path))
                        } else if let key = SharingRegex.parseSpirit(regex) {
                         let exist = SpiritBook.exists(with: key, in: context)
                         self.spirit.append(DownloadModel(size: size, name: name, loaded: exist, loading: false, path: path))
                         } // we are not ready for this
                    }
                }
            } else {
                print("No readable data is arrived")
            }
            self.allExists = allExist
            completition()
        }
        task.resume()
    }
}
