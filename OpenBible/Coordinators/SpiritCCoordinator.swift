//
//  SpiritCCoordinator.swift
//  OpenBible
//
//  Created by Denis Dobanda on 02.04.19.
//  Copyright © 2019 Denis Dobanda. All rights reserved.
//

import UIKit

class SpiritContainerCoordinator: ContainerCoordinator {
    
    var navigationController: UINavigationController
    
    var childCoordinators: [String : Coordinator]
    
    var rootViewController: ContainerViewController
    
    var previewCoordinator: SpiritPreviewCoordinator? {
        return childCoordinators["Preview"] as? SpiritPreviewCoordinator
    }
    
    var menuDelegate: MenuDelegate {
        return rootViewController
    }
    
    private lazy var spiritService = SpiritService()
    
    var menuCoordinator: MenuCoordinator? {
        get {
            if let c = childCoordinators["Menu"] as? MenuCoordinator {
                return c
            } else {
                let c = SpiritMenuCoordinator(navigationController)
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
        childCoordinators = [:]
        self.navigationController = navigationController
        rootViewController = ContainerViewController.instantiate()
        rootViewController.tabBarItem = UITabBarItem(title: "Spirit", image: UIImage(named: "dove"), tag: 0)
    }
    
    func start() {
        let preview = SpiritPreviewCoordinator(navigationController)
        preview.start()
        preview.menuDelegate = rootViewController
        rootViewController.coordinator = self
        childCoordinators["Preview"] = preview
    }
    
    func openURL(with parameters: [String]) -> Bool {
        return previewCoordinator?.openLink(parameters) ?? false
    }
}

extension SpiritContainerCoordinator {
    func didSelect(chapter: Int, in book: Int) {
        rootViewController.collapseMenu()
        spiritService.set(book: book)
        spiritService.set(chapter: chapter)
//        verseService.changeBook(to: book)
//        verseService.changeChapter(to: chapter)
    }
}
