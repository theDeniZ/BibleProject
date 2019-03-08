//
//  AppDelegate.swift
//  macB
//
//  Created by Denis Dobanda on 20.12.18.
//  Copyright © 2018 Denis Dobanda. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    private lazy var coreManager = CoreManager(AppDelegate.viewContext)
    private lazy var spiritManager = SpiritManager()
    private var plistManager = PlistManager()
    private var consistentManager = ConsistencyManager()
    
    static let downloadServerURL = "https://sword-ground.herokuapp.com/" //"http://192.168.178.25:3000/"
    static let URLServerRoot = "x-com-thedeniz-bible://"
    var urlToOpen: [String]?
    private var urlDelegate: URLDelegate?
    
    static var context: NSManagedObjectContext {
        return AppDelegate.shared.persistentContainer.newBackgroundContext()
    }
    
    static var viewContext: NSManagedObjectContext {
        return AppDelegate.shared.persistentContainer.viewContext
    }
    
    static var shared: AppDelegate {
        return NSApplication.shared.delegate as! AppDelegate
    }
    
    static var coreManager: CoreManager {
        return AppDelegate.shared.coreManager
    }
    
    static var spiritManager: SpiritManager {
        return AppDelegate.shared.spiritManager
    }
    
    static var plistManager: PlistManager {
        return AppDelegate.shared.plistManager
    }
    
    static var consistentManager: ConsistencyManager {
        return AppDelegate.shared.consistentManager
    }

    func applicationWillFinishLaunching(_ aNotification: Notification) {
        if !AppDelegate.isAppAlreadyLaunchedOnce {
            consistentManager.initialiseCoreData(to: AppDelegate.viewContext)
        }
        coreManager.update()
    }
    
    static func updateManagers() {
        coreManager.update(true)
        spiritManager.update(true)
    }

//    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
//    }
    
    static var isAppAlreadyLaunchedOnce: Bool {
        let defaults = UserDefaults.standard
        if defaults.string(forKey: "isAppAlreadyLaunchedOnce") != nil {
            return true
        } else {
            defaults.set(true, forKey: "isAppAlreadyLaunchedOnce")
            return false
        }
    }
    
    // MARK: - Manager controls
    
    @IBAction func chapterIncrement(_ sender: Any) {
        coreManager.incrementChapter()
    }
    @IBAction func chapterDecrement(_ sender: Any) {
        coreManager.decrementChapter()
    }
    @IBAction func bookIncrement(_ sender: Any) {
        coreManager.incrementBook()
    }
    @IBAction func bookDecrement(_ sender: Any) {
        coreManager.decrementBook()
    }
    @IBAction func fontIncrement(_ sender: Any) {
        coreManager.incrementFont()
    }
    @IBAction func fontDecrement(_ sender: Any) {
        coreManager.decrementFont()
    }
    
    // MARK: - URL control
    
    func application(_ application: NSApplication, open urls: [URL]) {
        guard urls.count > 0 else {return}
        let urlStr: String = urls[0].absoluteString
        let count = AppDelegate.URLServerRoot.count
        let parameters = String(urlStr[urlStr.index(urlStr.startIndex, offsetBy: count)...])
        urlToOpen = parameters.split(separator: "/").map{String($0)}
        openUrlIfNeeded()
    }
    
    static func setDelegate(aDelegate: URLDelegate?) {
        AppDelegate.shared.urlDelegate = aDelegate
        AppDelegate.shared.openUrlIfNeeded()
    }
    
    private func openUrlIfNeeded() {
        if urlToOpen != nil, urlDelegate != nil {
            urlDelegate!.openedURL(with: urlToOpen!)
            urlToOpen = nil
        }
    }
    
    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "macB")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error {
                fatalError("Unresolved error \(error)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving and Undo support

    @IBAction func saveAction(_ sender: AnyObject?) {
        let context = persistentContainer.viewContext

        if !context.commitEditing() {
            NSLog("\(NSStringFromClass(type(of: self))) unable to commit editing before saving")
        }
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                NSApplication.shared.presentError(nserror)
            }
        }
    }

    func windowWillReturnUndoManager(window: NSWindow) -> UndoManager? {
        return persistentContainer.viewContext.undoManager
    }

    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        let context = persistentContainer.viewContext
        if !context.commitEditing() {
            NSLog("\(NSStringFromClass(type(of: self))) unable to commit editing to terminate")
            return .terminateCancel
        }
        if !context.hasChanges {
            return .terminateNow
        }
        do {
            try context.save()
        } catch {
            let nserror = error as NSError
            let result = sender.presentError(nserror)
            if (result) {
                return .terminateCancel
            }
            let question = NSLocalizedString("Could not save changes while quitting. Quit anyway?", comment: "Quit without saves error question message")
            let info = NSLocalizedString("Quitting now will lose any changes you have made since the last successful save", comment: "Quit without saves error question info");
            let quitButton = NSLocalizedString("Quit anyway", comment: "Quit anyway button title")
            let cancelButton = NSLocalizedString("Cancel", comment: "Cancel button title")
            let alert = NSAlert()
            alert.messageText = question
            alert.informativeText = info
            alert.addButton(withTitle: quitButton)
            alert.addButton(withTitle: cancelButton)
            
            let answer = alert.runModal()
            if answer == .alertSecondButtonReturn {
                return .terminateCancel
            }
        }
        return .terminateNow
    }
}
