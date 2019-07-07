//
//  MainTabBar.swift
//  SplitB
//
//  Created by Denis Dobanda on 17.12.18.
//  Copyright © 2018 Denis Dobanda. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController, UITabBarControllerDelegate {
    
//    lazy var main: ContainerViewController! = ContainerViewController.instantiate()
    let main = MainContainerCoordinator(UINavigationController())
    let spirit = SpiritContainerCoordinator(UINavigationController())
    let load = MainDownloadCoordinator(UINavigationController())
    let settings = MainSettingsCoordinator(UINavigationController())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        main.start()
        spirit.start()
        load.start()
        settings.start()
        settings.previewCoordinator = main.previewCoordinator
        viewControllers = [
            main.rootViewController,
//            spirit.rootViewController,
            load.navigationController,
            settings.navigationController
        ]
        
        AppDelegate.shared.urlDelegate = self
        
    }
    
}

extension MainTabBarController: URLDelegate {
    func openedURL(with parameters: [String]) {
        if main.openURL(with: parameters) {
            selectedIndex = 0
        } else if spirit.openURL(with: parameters) {
            selectedIndex = 1
        }
    }
}
