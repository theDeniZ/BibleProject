//
//  MainCoordinator.swift
//  OpenBible
//
//  Created by Denis Dobanda on 24.03.19.
//  Copyright © 2019 Denis Dobanda. All rights reserved.
//

import UIKit

class MainPreviewCoordinator: NSObject, Coordinator {
    var childCoordinators: [String:Coordinator] = [:]
    
    var navigationController: UINavigationController
    var menuDelegate: MenuDelegate?
    
    var rootViewController: MultipleTextVC?
    
    required init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        navigationController.delegate = self
        let vc = MultipleTextVC.instantiate()
        vc.tabBarItem = UITabBarItem(title: "Read", image: UIImage(named: "book"), tag: 0)
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: false)
        rootViewController = vc
    }
    
    func toggleMenu() {
        menuDelegate?.toggleMenu()
    }
    
    func openLink(_ parameters: [String]) {
        menuDelegate?.collapseMenu()
        if parameters.count > 1 {
            switch parameters[0] {
            case StrongId.oldTestament, StrongId.newTestament:
                let strong = MainStrongCoordinator(navigationController, parameters: parameters)
                strong.start()
                childCoordinators["Strong"] = strong
            default: break
            }
        } else {
            rootViewController?.doSearch(text: parameters[0])
        }
    }
    
    func dismiss(_ coordinator: Coordinator) {
        if coordinator is MainStrongCoordinator {
            childCoordinators.removeValue(forKey: "Strong")
            print("removed strong coord")
        }
    }
}

extension MainPreviewCoordinator: PreviewCoordinator {
    func setNeedsUpdate() {
        rootViewController?.setNeedsLoad()
    }
}

extension MainPreviewCoordinator: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        guard let fromVC = navigationController.transitionCoordinator?.viewController(forKey: .from) else {return}
        if navigationController.viewControllers.contains(fromVC) {return}
        
        if fromVC is StrongViewController {
            childCoordinators.removeValue(forKey: "Strong")
            print("removed strong coord")
        }
    }
}
