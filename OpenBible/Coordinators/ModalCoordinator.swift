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
//        navigationController.present(vc, animated: true, completion: nil)
        let nvc = UINavigationController(rootViewController: vc)
//        nvc.delegate = self
        nvc.modalPresentationStyle = UIModalPresentationStyle.popover
        let popover = nvc.popoverPresentationController
//        vc.preferredContentSize = size
//        if let view = rootViewController?.view {
            popover?.sourceView = vc.view
//            popover?.sourceRect = CGRect(x: (view.bounds.width / 2), y: (view.bounds.height / 2), width: 0, height: 0)
//        }
//        popover?.permittedArrowDirections = .init(rawValue: 0)
        //        popover?.backgroundColor = UIColor.green
        
        navigationController.present(nvc, animated: true, completion: nil)
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
//
//extension MainModalCoordinator: UINavigationControllerDelegate {
//    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
//        guard let fromVC = navigationController.transitionCoordinator?.viewController(forKey: .from) else {return}
//        if navigationController.viewControllers.contains(fromVC) {return}
//
//        if fromVC is ModalViewController {
////            childCoordinators.removeValue(forKey: "Strong")
//            print("removed modal coord")
//            parent?.dismiss(self)
//        }
//    }
//}
