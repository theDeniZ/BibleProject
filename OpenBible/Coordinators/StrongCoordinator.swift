//
//  StrongCoordinator.swift
//  OpenBible
//
//  Created by Denis Dobanda on 27.03.19.
//  Copyright © 2019 Denis Dobanda. All rights reserved.
//

import UIKit

class MainStrongCoordinator: NSObject, Coordinator {

    var navigationController: UINavigationController
    
    var childCoordinators: [String : Coordinator]
    
    var service: StrongService
    
    var parent: MainPreviewCoordinator?
    
    required init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
        childCoordinators = [:]
        service = StrongService([])
    }
    
    init(_ navigationController: UINavigationController, parameters: [String]) {
        self.navigationController = navigationController
        childCoordinators = [:]
        service = StrongService(parameters)
    }
    
    func start() {
        let vc = StrongViewController.instantiate()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
    
    var title: String {
        return service.getTitle()
    }
    
    var text: String {
        return service.getText() ?? ""
    }
    
    func dismiss() {
        parent?.dismiss(self)
    }
}
