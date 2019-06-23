//
//  SpiritPCoordinator.swift
//  OpenBible
//
//  Created by Denis Dobanda on 02.04.19.
//  Copyright © 2019 Denis Dobanda. All rights reserved.
//

import UIKit

class SpiritPreviewCoordinator: NSObject, PreviewCoordinator {
    
//    var coordinator: ModelVerseDelegate
    
    var childCoordinators: [String:Coordinator] = [:]
    
    var navigationController: UINavigationController
    var menuDelegate: MenuDelegate?
    
    var rootViewController: MultipleTextVC?
    var modelVerseDelegate: ModelVerseDelegate {
        return service.modelVerseDelegate
    }
    
    var service = PreviewSpiritService()
    
    required init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        service.addDelegate(self)
        navigationController.delegate = self
        let vc = MultipleTextVC.instantiate()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: false)
        rootViewController = vc
    }
    
    func setNeedsUpdate() {
        rootViewController?.setNeedsLoad()
    }
    
    func openLink(_ parameters: [String]) -> Bool {
        menuDelegate?.collapseMenu()
        if parameters.count > 1, parameters[0].lowercased() == "spirit" {
            return doSearch(text: parameters[1])
        }
        return false
        
    }
    
    
    func doSearch(text: String) -> Bool {
        if let index = service.find(text: text) {
            rootViewController?.scroll(to: (0, index))
            return true
        }
        return false
    }
    
    func toggleMenu() {
        menuDelegate?.toggleMenu()
    }
    
    func pinch(_ value: CGFloat) {
        
    }
    
    func collapseIfNeeded() {
        menuDelegate?.collapseMenu()
    }
}

extension SpiritPreviewCoordinator: ModelUpdateDelegate {
    func modelChanged(_ fully: Bool) {
        rootViewController?.loadTextViews()
    }
}

extension SpiritPreviewCoordinator: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        guard let fromVC = navigationController.transitionCoordinator?.viewController(forKey: .from) else {return}
        if navigationController.viewControllers.contains(fromVC) {return}
        
        if fromVC is StrongViewController {
            childCoordinators.removeValue(forKey: "Strong")
            print("removed strong coord")
        }
    }
}


extension SpiritPreviewCoordinator {
    override var description: String {
        return service.description
    }
    
    func getDataToPresent() -> [[Presentable]] {
        return service.getDataToPresent()
    }
    
    func swipe(_ direction: SwipeDirection) {
        switch direction {
        case .left:
            service.increment()
        case .right:
            service.decrement()
        }
    }
}

extension SpiritPreviewCoordinator {
    
    func presentNote(at index: (Int, Int)) {
        //        guard let note = verseManager.isThereANote(at: index) else {return}
        presentMenu(at: index)
    }
    
    func presentMenu(at index: (Int, Int)) {
        guard index.1 > 0 else {return}
        if UIDevice.current.userInterfaceIdiom == .phone {
            AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
            presentOniPhone(at: index)
        } else {
            presentOniPad(at: index)
        }
        collapseIfNeeded()
    }
    
    func presentOniPhone(at index: (Int, Int)) {
        let pvc = NoteViewController.instantiate()
        pvc.modalPresentationStyle = UIModalPresentationStyle.custom
        pvc.transitioningDelegate = self
        pvc.delegate = modelVerseDelegate
        pvc.resignDelegate = self
        pvc.index = index
        rootViewController?.scroll(to: index)
        navigationController.present(pvc, animated: true, completion: nil)
    }
    
    func presentOniPad(at index: (Int, Int)) {
        let pvc = NoteViewController.instantiate()
        
        pvc.delegate = modelVerseDelegate
        pvc.resignDelegate = self
        pvc.index = index
        pvc.makingCustomSize = false
        rootViewController?.scroll(to: index)
        
        let size = CGSize(width: 300, height: 300)
        present(vc: pvc, with: size)
        //        self.present(pvc, animated: true, completion: nil)
    }
    
    private func present(vc: UIViewController, with size: CGSize) {
        let nvc = UINavigationController(rootViewController: vc)
        nvc.modalPresentationStyle = UIModalPresentationStyle.popover
        let popover = nvc.popoverPresentationController
        vc.preferredContentSize = size
        if let view = rootViewController?.view {
            popover?.sourceView = view
            popover?.sourceRect = CGRect(x: (view.bounds.width / 2), y: (view.bounds.height / 2), width: 0, height: 0)
        }
        popover?.permittedArrowDirections = .init(rawValue: 0)
        //        popover?.backgroundColor = UIColor.green
        
        navigationController.present(nvc, animated: true, completion: nil)
    }
}

extension SpiritPreviewCoordinator: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return HalfSizePresentationController(presentedViewController: presented, presenting: presenting)
    }
}

extension SpiritPreviewCoordinator: UIResignDelegate {
    func viewControllerWillResign() {
        rootViewController?.setNeedsLoad()
    }
}
