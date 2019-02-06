//
//  MainTabBar.swift
//  SplitB
//
//  Created by Denis Dobanda on 17.12.18.
//  Copyright © 2018 Denis Dobanda. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        if !AppDelegate.isAppAlreadyLaunchedOnce || Module.count(in: AppDelegate.context) == 0 {
            selectedIndex = 1
        }
        delegate = self
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if viewController as? ContainerViewController != nil {
            return Module.count(in: AppDelegate.context) > 0
        }
        return true
    }
    
}
