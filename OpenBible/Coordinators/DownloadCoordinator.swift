//
//  DownloadCoordinator.swift
//  OpenBible
//
//  Created by Denis Dobanda on 24.03.19.
//  Copyright © 2019 Denis Dobanda. All rights reserved.
//

import UIKit

class MainDownloadCoordinator: NSObject, DownloadCoordinator {
    
    var childCoordinators: [String:Coordinator] = [:]
    
    var navigationController: UINavigationController
    
    var modules: [DownloadModel] {return service.modules}
    
    var strongs: [DownloadModel] {return service.strongs}
    
    var spirit: [DownloadModel] {return service.spirit}
    
    var allExists: Bool {return service.allExists}
    
    private var service = DownloadService()
    
    required init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let vc = DownloadVC.instantiate()
        vc.coordinator = self
        vc.tabBarItem = UITabBarItem(title: "Download", image: UIImage(named: "load"), tag: 0)
        navigationController.pushViewController(vc, animated: false)
    }
    
    func readFromServer(completition: @escaping () -> ()) {
        service.readFromServer(completition: completition)
    }
    
    func download(_ file: String, completition: @escaping (Bool) -> ()) {
        service.download(file, completition: completition)
    }
    
    func remove(_ file: String, completition: @escaping () -> ()) {
        service.remove(file, completition: completition)
    }
    
}
