//
//  GeneralContainerCoordinator.swift
//  OpenBible
//
//  Created by Denis Dobanda on 24.03.19.
//  Copyright © 2019 Denis Dobanda. All rights reserved.
//

import UIKit

class MainMenuCoordinator: NSObject, MenuCoordinator {
    
    var navigationController: UINavigationController
    var childCoordinators: [String:Coordinator]
    var rootViewController: LeftSelectionViewController
    
    weak var parent: MainContainerCoordinator?
    
    private lazy var service = MenuService()
    
    required init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
        rootViewController = LeftSelectionViewController.instantiate()
        childCoordinators = [:]
    }
    
    func start() {
        rootViewController.coordinator = self
    }
    
    func presentPicker() {
        let picker = MainModalCoordinator(navigationController)
        picker.start()
        picker.parent = self
        childCoordinators["Picker"] = picker
    }
    
    func presentHistory() {
        
    }
    
    func getItemsToPresent() -> [[ListExpandablePresentable]] {
        return service.getItemsToPresent()
    }
    
    var selectedBookIndexPath: IndexPath {
        return service.bookIndexPath
    }
    
    func getKeysTitle() -> String {
        return service.getKeysTitle()
    }
    
    func didSelect(chapter: Int, in book: Int) {
        parent?.didSelect(chapter: chapter, in: book)
    }
    
    func dismiss(_ coordinator: Coordinator) {
        if coordinator is MainModalCoordinator {
            childCoordinators["Picker"] = nil
            parent?.menuDelegate.collapseMenu()
        }
    }
}
