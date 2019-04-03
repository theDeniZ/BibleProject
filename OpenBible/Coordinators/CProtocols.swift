//
//  CProtocols.swift
//  OpenBible
//
//  Created by Denis Dobanda on 24.03.19.
//  Copyright © 2019 Denis Dobanda. All rights reserved.
//

import UIKit

protocol Coordinator: AnyObject {
    var navigationController: UINavigationController {get set}
    var childCoordinators: [String:Coordinator] {get set}
    
    init(_ navigationController: UINavigationController)
    func start()
}

protocol ContainerCoordinator: Coordinator {
    var menuCoordinator: MenuCoordinator? {get set}
    var menuDelegate: MenuDelegate {get}
    
    func didSelect(chapter: Int, in book: Int)
}

protocol PreviewCoordinator: Coordinator, UIPresentee {
    var description: String {get}
    var modelVerseDelegate: ModelVerseDelegate {get}
    
    func doSearch(text: String) -> Bool
    func getDataToPresent() -> [[Presentable]]
    func toggleMenu()
    func openLink(_ parameters: [String]) -> Bool
    func swipe(_ direction: SwipeDirection)
    
    func setNeedsUpdate()
}

protocol MenuCoordinator: Coordinator {
    var selectedBookIndexPath: IndexPath {get}
    var rootViewController: LeftSelectionViewController {get}
    
    func getItemsToPresent() -> [[ListExpandablePresentable]]
    func getKeysTitle() -> String
    
    func presentPicker()
    func presentHistory()
    func didSelect(chapter: Int, in book: Int)
}

protocol DownloadCoordinator: Coordinator {
    var modules: [DownloadModel] {get}
    var strongs: [DownloadModel] {get}
    var spirit: [DownloadModel] {get}
    var allExists: Bool {get}
    
    func readFromServer(completition: @escaping () -> ())
    func download(_ file: String, completition: @escaping (Bool) -> () )
    func remove(_ file: String, completition: @escaping () -> () )
}

protocol SettingsCootrinator: Coordinator {
    var isStrongsOn: Bool {get set}
    var modulesCount: Int {get set}
}

protocol MenuDelegate {
    func toggleMenu()
    func collapseMenu()
}

// MARK: - Storyboard

protocol Storyboarded {
    static func instantiate() -> Self
}

extension Storyboarded where Self: UIViewController {
    static func instantiate() -> Self {
        let id = String(describing: self)
        return UIStoryboard.main().instantiateViewController(withIdentifier: id) as! Self
    }
}
