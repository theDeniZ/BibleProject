//
//  MainContainerCoordinator.swift
//  OpenBible
//
//  Created by Denis Dobanda on 25.03.19.
//  Copyright © 2019 Denis Dobanda. All rights reserved.
//

import UIKit

class MainContainerCoordinator: ContainerCoordinator {
    
    var navigationController: UINavigationController
    
    var childCoordinators: [String:Coordinator]
    
    var rootViewController: ContainerViewController
    
    var previewCoordinator: MainPreviewCoordinator? {
        return childCoordinators["Preview"] as? MainPreviewCoordinator
    }
    
    var menuDelegate: MenuDelegate {
        return rootViewController
    }
    
    private lazy var verseService = VerseService()
    
    var menuCoordinator: MenuCoordinator? {
        get {
            if let c = childCoordinators["Menu"] as? MainMenuCoordinator {
                return c
            } else {
                let c = MainMenuCoordinator(navigationController)
                c.parent = self
                childCoordinators["Menu"] = c
                return c
            }
        }
        set {
            childCoordinators["Menu"] = newValue
        }
    }
    
    required init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
        childCoordinators = [:]
        rootViewController = ContainerViewController.instantiate()
        rootViewController.tabBarItem = UITabBarItem(title: "Bible", image: UIImage(named: "book"), tag: 0)
    }
    
    func start() {
        let preview = MainPreviewCoordinator(navigationController)
        preview.start()
        preview.menuDelegate = rootViewController
        rootViewController.coordinator = self
//        navigationController.pushViewController(rootViewController, animated: false)
        childCoordinators["Preview"] = preview
    }
    
    func openURL(with parameters: [String]) -> Bool {
        return previewCoordinator?.openLink(parameters) ?? false
    }
    
}

extension MainContainerCoordinator {
    func didSelect(chapter: Int, in book: Int) {
        rootViewController.collapseMenu()
        _=previewCoordinator?.service.changeBook(to: book)
        previewCoordinator?.service.changeChapter(to: chapter)
    }
}
