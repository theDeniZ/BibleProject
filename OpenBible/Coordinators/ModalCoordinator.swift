//
//  ModalCoordinator.swift
//  OpenBible
//
//  Created by Denis Dobanda on 27.03.19.
//  Copyright © 2019 Denis Dobanda. All rights reserved.
//

import UIKit

class MainModalCoordinator: Coordinator {
    
    var navigationController: UINavigationController
    
    var childCoordinators: [String : Coordinator]
    
    var service = ModalPickerService()
    
    var parent: MainMenuCoordinator?
    
    required init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
        childCoordinators = [:]
    }
    
    func start() {
        let vc = ModalViewController.instantiate()
        vc.coordinator = self
//        navigationController.pushViewController(vc, animated: true)
        navigationController.present(vc, animated: true, completion: nil)
    }
    
    func getNotSelectedModules() -> [(String, String)] {
        return service.getNotSelectedModules()
    }
    
    func getSelectedModules() -> [(String, String)] {
        return service.getSelectedModules()
    }
    
    func insert(_ module: (String, String), at position: Int) {
        service.insert(module, at: position)
    }
    
    func removeModule(at position: Int) {
        service.removeModule(at: position)
    }
    
    func swapModulesAt(_ first: Int, _ second: Int) {
        service.swapModulesAt(first, second)
    }
    
    func dismiss() {
        parent?.dismiss(self)
    }
    
}
