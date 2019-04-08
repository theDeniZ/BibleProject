//
//  RootCoordinator.swift
//  OpenBible
//
//  Created by Denis Dobanda on 25.03.19.
//  Copyright © 2019 Denis Dobanda. All rights reserved.
//

//import UIKit
//
//class RootCoordinator: NSObject, Coordinator {
//
//    var navigationController: UINavigationController
//    var childCoordinators: [Coordinator]
//
//    init(_ navigationController: UINavigationController) {
//        self.navigationController = navigationController
//        childCoordinators = []
//    }
//
//    func start() {
//        let vc = MainTabBarController()
////        setup(vc)
//        navigationController.pushViewController(vc, animated: false)
//    }
////    private func setup(_ tabBarController: MainTabBarController) {
////        let main = MainContainerCoordinator(UINavigationController())
////        let load = MainDownloadCoordinator(UINavigationController())
////        let sett = MainSettingsCoordinator(UINavigationController())
////        tabBarController.main = main
////        tabBarController.load = load
////        tabBarController.settings = sett
////        tabBarController.initialise()
////        let array: [Coordinator] = [main, load, sett]
////        childCoordinators.append(contentsOf: array)
////    }
//}
