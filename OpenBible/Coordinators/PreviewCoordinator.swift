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
//    var modelVerseDelegate: ModelVerseDelegate {
//        return service.modelVerseDelegate
//    }
    
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
                rootViewController?.barsVisible = true
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
//            print("removed strong coord")
        }
    }
    
    func setNeedsUpdate() {
        rootViewController?.setNeedsLoad()
    }
    
    func collapseIfNeeded() {
        menuDelegate?.collapseMenu()
    }
}

extension MainPreviewCoordinator: ModelUpdateDelegate {
    func modelChanged(_ fully: Bool) {
        rootViewController?.loadTextViews()
        rootViewController?.scrollToTop(animated: true)
    }
}

extension MainPreviewCoordinator {
    func doSearch(text arrived: String) -> Bool {
        
        var indices: [BibleIndex] = []
        
        let searches = arrived.split(separator: ";")
        for arrivedOne in searches {
            let text = arrivedOne.replacingOccurrences(of: " ", with: "")
            if text.matches(String.regexForChapter) {
                let m = text.capturedGroups(withRegex: String.regexForChapter)!
                service.changeChapter(to: Int(m[0])!)
            } else if text.matches(String.regexForBookRefference) {
                let match = text.capturedGroups(withRegex: String.regexForBookRefference)!
                
                var prevIndex = service.bibleIndex(for: indices.count)
                if let bookIndex = service.bookIndex(for: match[0]) {
                    prevIndex.book = bookIndex
                }
                if let chapter = Int(match[1]) {
                    prevIndex.chapter = chapter
                }
                if let verseMatch = text.matches(withRegex: String.regexForVerses) {
                    let v = verseMatch[1...].map {$0[0]}
                    let ranges = getVerseRanges(from: v)
                    prevIndex.verses = ranges.count > 0 ? ranges : nil
                }
                indices.append(prevIndex)
            } else if text.matches(String.regexForVersesOnly) {
                let verseMatch = text.matches(withRegex: String.regexForVersesOnly)!
                var prevIndex = service.bibleIndex(for: indices.count)
                if let chapter = Int(verseMatch[0][0]) {
                    prevIndex.chapter = chapter
                }
                let v = verseMatch[1...].map {$0[0]}
                if v.count > 0 {
                    let verses = getVerseRanges(from: v)
                    prevIndex.verses = verses.count > 0 ? verses : nil
                }
                indices.append(prevIndex)
            }
        }
        service.setIndices(indices)
        rootViewController?.scrollToTop(animated: false)
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
    
    func getDataToPresent() -> CollectionPresentable {
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
    
    func pinch(_ value: CGFloat) {
        service.zoom(incrementingTo: Double(value))
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
        collapseIfNeeded()
    }
    
    private func presentOniPhone(at index: (Int, Int)) {
        let pvc = NoteViewController.instantiate()
        pvc.modalPresentationStyle = UIModalPresentationStyle.custom
        pvc.transitioningDelegate = self
//        pvc.delegate = modelVerseDelegate
        pvc.resignDelegate = self
        pvc.index = index
        rootViewController?.scroll(to: (0,index))
        navigationController.present(pvc, animated: true, completion: nil)
    }
    
    private func presentOniPad(at index: (Int, Int)) {
        let pvc = NoteViewController.instantiate()
//        pvc.delegate = modelVerseDelegate
        pvc.resignDelegate = self
        pvc.index = index
        pvc.makingCustomSize = false
        rootViewController?.scroll(to: (0,index))
        
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
