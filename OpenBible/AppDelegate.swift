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
    private var urlToOpen: [String]? {didSet{openUrlIfNeeded()}}
    
    static var URLServerRoot = "x-com-thedeniz-bible://"
    
    static var shared: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    static var plistManager: PlistManager {
        return AppDelegate.shared.plistManager
    }
    
    private var plistManager = PlistManager()
    
//    @objc func getUrl(_ event: NSAppleEventDescriptor, withReplyEvent replyEvent: NSAppleEventDescriptor) {
//        // Get the URL
//        let urlStr: String = event.paramDescriptor(forKeyword: keyDirectObject)!.stringValue!
//        let count = AppDelegate.URLServerRoot.count
//        let parameters = String(urlStr[urlStr.index(urlStr.startIndex, offsetBy: count)...])
//        urlDelegate?.openedURL(with: parameters.split(separator: "/").map{String($0)})
//    }

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
    
    static var isAppAlreadyLaunchedOnce: Bool {
        let defaults = UserDefaults.standard
        if defaults.string(forKey: "isAppAlreadyLaunchedOnce") != nil {
            return true
        } else {
            defaults.set(true, forKey: "isAppAlreadyLaunchedOnce")
            return false
        }
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey:Any]?) -> Bool {
//        let em = NSAppleEventManager.shared()
//        em.setEventHandler(self, andSelector: #selector(self.getUrl(_:withReplyEvent:)), forEventClass: AEEventClass(kInternetEventClass), andEventID: AEEventID(kAEGetURL))
        return true
    }

//    func applicationWillResignActive(_ application: UIApplication) {
//        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
//        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
//    }
//
//    func applicationDidEnterBackground(_ application: UIApplication) {
//        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
//        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
//    }
//
//    func applicationWillEnterForeground(_ application: UIApplication) {
//        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
//    }
//
//    func applicationDidBecomeActive(_ application: UIApplication) {
//        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
//    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if url.host == nil
        {
            return true;
        }
        let urlString = url.absoluteString
        let queryArray = urlString.components(separatedBy: "/")
        let query = queryArray[2]
        
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
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "OpenBible")
        container.loadPersistentStores(completionHandler:{ (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
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
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

