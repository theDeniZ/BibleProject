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
    let load = MainDownloadCoordinator(UINavigationController())
    let settings = MainSettingsCoordinator(UINavigationController())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        main.start()
        load.start()
        settings.start()
        settings.previewCoordinator = main.previewCoordinator
        viewControllers = [main.rootViewController, load.navigationController, settings.navigationController]
        
    }
    
}
