//
//  AppDelegate.swift
//  SplitB
//
//  Created by Denis Dobanda on 18.10.18.
//  Copyright © 2018 Denis Dobanda. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var urlDelegate: URLDelegate? {didSet{openUrlIfNeeded()}}
    var consistentManager: ConsistencyManager!
    
    private lazy var manager: VerseManager = VerseManager(AppDelegate.viewContext)
    
    private var urlToOpen: [String]? {didSet{openUrlIfNeeded()}}
    
    static let URLServerRoot = "x-com-thedeniz-bible://"
    static let downloadServerURL = "https://sword-ground.herokuapp.com/api/" //"http://192.168.178.25:3000/"
    
    static var coreManager: VerseManager {
        return AppDelegate.shared.manager
    }
    
    static var shared: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    static var plistManager: PlistManager {
        return AppDelegate.shared.plistManager
    }
    
    private var plistManager = PlistManager()
    
    var orientationLock = UIInterfaceOrientationMask.all
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return self.orientationLock
    }

    static var persistantContainer: NSPersistentContainer {
        get {
            return (UIApplication.shared.delegate as! AppDelegate).persistentContainer
        }
    }
    
    static var context: NSManagedObjectContext {
        get {
            return AppDelegate.persistantContainer.newBackgroundContext()
        }
    }
    
    static var viewContext: NSManagedObjectContext {
        return AppDelegate.persistantContainer.viewContext
    }
    
    static var isAppAlreadyLaunchedOnce: Bool {
        let defaults = UserDefaults.standard
        if defaults.string(forKey: "isAppAlreadyLaunchedOnce") != nil {
            return true
        } else {
            defaults.set(true, forKey: "isAppAlreadyLaunchedOnce")
            return false
        }
    }

    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        consistentManager = ConsistencyManager(context: persistentContainer.newBackgroundContext())
        consistentManager.addDelegate(self)
        if !AppDelegate.isAppAlreadyLaunchedOnce {
            print("initialised")
            consistentManager.initialiseCoreData()
        }
        manager.update(true)
        return true
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey:Any]?) -> Bool {
//        consistentManager = ConsistencyManager(context: persistentContainer.newBackgroundContext())
//        consistentManager.addDelegate(self)
//        if !AppDelegate.isAppAlreadyLaunchedOnce {
//            print("initialised")
//            consistentManager.initialiseCoreData()
//        }
//        manager.update(true)
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = MainTabBarController()
        window?.makeKeyAndVisible()
        return true
    }

    func applicationWillTerminate(_ application: UIApplication) {
        self.saveContext()
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if url.host == nil
        {
            return true;
        }
        let urlString = url.absoluteString
        let startIndex = urlString.index(urlString.startIndex, offsetBy: AppDelegate.URLServerRoot.count)
        let query = urlString[startIndex...]
        
        urlToOpen = query.split(separator: "/").map{String($0)}
        
        return true
    }

    private func openUrlIfNeeded() {
        if urlToOpen != nil, urlDelegate != nil {
            urlDelegate?.openedURL(with: urlToOpen!)
            urlToOpen = nil
        }
    }
    
    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "OpenBible")
        container.loadPersistentStores(completionHandler:{ (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

extension AppDelegate: ConsistencyManagerDelegate {
    func consistentManagerDidChangedModel() {
        print("modelChanged")
    }
}

struct AppUtility {
    
    static func lockOrientation(_ orientation: UIInterfaceOrientationMask) {
        AppDelegate.shared.orientationLock = orientation
    }
    
    /// OPTIONAL Added method to adjust lock and rotate to the desired orientation
    static func lockOrientation(_ orientation: UIInterfaceOrientationMask, andRotateTo rotateOrientation:UIInterfaceOrientation) {
        
        self.lockOrientation(orientation)
        
        UIDevice.current.setValue(rotateOrientation.rawValue, forKey: "orientation")
        UINavigationController.attemptRotationToDeviceOrientation()
    }
    
}
