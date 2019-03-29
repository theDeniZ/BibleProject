//
//  SettingsCoordinator.swift
//  OpenBible
//
//  Created by Denis Dobanda on 25.03.19.
//  Copyright © 2019 Denis Dobanda. All rights reserved.
//

import UIKit

class MainSettingsCoordinator: NSObject, SettingsCootrinator {
    
    var previewCoordinator: PreviewCoordinator?
    var isStrongsOn: Bool {
        get {
            return service.isStrongsOn
        }
        set {
            service.isStrongsOn = newValue
            previewCoordinator?.setNeedsUpdate()
        }
    }
    
    var modulesCount: Int {
        get {
            return service.numberOfModules
        }
        set {
            service.numberOfModules = newValue
            previewCoordinator?.setNeedsUpdate()
        }
    }
    
    var navigationController: UINavigationController
    
    var childCoordinators: [String:Coordinator] = [:]
    
    required init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    private var service = SettingService()
    
    func start() {
        let vc = SettingsViewController.instantiate()
        vc.coordinator = self
        vc.tabBarItem = UITabBarItem(title: "Settings", image: UIImage(named: "settings"), tag: 0)
        navigationController.pushViewController(vc, animated: false)
    }
    
    
}
