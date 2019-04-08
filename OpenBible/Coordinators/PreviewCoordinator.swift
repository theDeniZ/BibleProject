//
//  MainCoordinator.swift
//  OpenBible
//
//  Created by Denis Dobanda on 24.03.19.
//  Copyright © 2019 Denis Dobanda. All rights reserved.
//

import UIKit

class MainPreviewCoordinator: NSObject, PreviewCoordinator {
    
    var childCoordinators: [String:Coordinator] = [:]
    
    var navigationController: UINavigationController
    var menuDelegate: MenuDelegate?
    
    var rootViewController: MultipleTextVC?
    var modelVerseDelegate: ModelVerseDelegate {
        return service.modelVerseDelegate
    }
    
    var service = PreviewModuleService()
    
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
    
    func toggleMenu() {
        menuDelegate?.toggleMenu()
    }
    
    func openLink(_ parameters: [String]) -> Bool {
        menuDelegate?.collapseMenu()
        if parameters.count > 1 {
            switch parameters[0] {
            case StrongId.oldTestament, StrongId.newTestament:
                let strong = MainStrongCoordinator(navigationController, parameters: parameters)
                strong.start()
                if UIDevice.current.userInterfaceIdiom == .phone {
                    strong.present()
                } else {
                    if let vc = strong.rootViewController {
                        present(vc: vc, with: CGSize(width: 400, height: 400))
                    }
                }
                childCoordinators["Strong"] = strong
                return true
            default: break
            }
        } else {
            return doSearch(text: parameters[0])
        }
        return false
    }
    
    func dismiss(_ coordinator: Coordinator) {
        if coordinator is MainStrongCoordinator {
            childCoordinators.removeValue(forKey: "Strong")
            print("removed strong coord")
        }
    }
    
    func setNeedsUpdate() {
        rootViewController?.setNeedsLoad()
    }
}

extension MainPreviewCoordinator: ModelUpdateDelegate {
    func modelChanged(_ fully: Bool) {
        rootViewController?.loadTextViews()
    }
}

extension MainPreviewCoordinator {
    func doSearch(text arrived: String) -> Bool {
        let text = arrived.replacingOccurrences(of: " ", with: "")
        if text.matches(String.regexForChapter) {
            let m = text.capturedGroups(withRegex: String.regexForChapter)!
            service.changeChapter(to: Int(m[0])!)
        } else if text.matches(String.regexForBookRefference) {
            let match = text.capturedGroups(withRegex: String.regexForBookRefference)!
            if service.changeBook(by: match[0]),
                match.count > 1,
                let n = Int(match[1]) {
                service.changeChapter(to: n)
                if match.count > 2,
                    let verseMatch = text.matches(withRegex: String.regexForVerses),
                    verseMatch[0][0] == match[1] {
                    let v = verseMatch[1...]
                    service.setVerses(from: v.map {$0[0]})
                }
            }
        } else if text.matches(String.regexForVersesOnly) {
            let verseMatch = text.matches(withRegex: String.regexForVersesOnly)!
            service.changeChapter(to: Int(verseMatch[0][0])!)
            let v = verseMatch[1...]
            if v.count > 0 {
                service.setVerses(from: v.map {$0[0]})
            }
        } else {
            return false
        }
        return true
//        loadTextViews()
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

extension MainPreviewCoordinator {
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

extension MainPreviewCoordinator {
    
    func presentNote(at index: (Int, Int)) {
        //        guard let note = verseManager.isThereANote(at: index) else {return}
        presentMenu(at: index)
    }
    
    func presentMenu(at index: (Int, Int)) {
        if UIDevice.current.userInterfaceIdiom == .phone {
            AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
            presentOniPhone(at: index)
        } else {
            presentOniPad(at: index)
        }
    }
    
    private func presentOniPhone(at index: (Int, Int)) {
        let pvc = NoteViewController.instantiate()
        pvc.modalPresentationStyle = UIModalPresentationStyle.custom
        pvc.transitioningDelegate = self
        pvc.delegate = modelVerseDelegate
        pvc.resignDelegate = self
        pvc.index = index
        rootViewController?.scroll(to: index)
        navigationController.present(pvc, animated: true, completion: nil)
    }
    
    private func presentOniPad(at index: (Int, Int)) {
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


enum SwipeDirection {
    case left, right
}

extension MainPreviewCoordinator: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return HalfSizePresentationController(presentedViewController: presented, presenting: presenting)
    }
}

class HalfSizePresentationController : UIPresentationController {
    override var frameOfPresentedViewInContainerView: CGRect {
        return containerView!.bounds
    }
}

extension MainPreviewCoordinator: UIResignDelegate {
    func viewControllerWillResign() {
        rootViewController?.reloadData()
    }
}
