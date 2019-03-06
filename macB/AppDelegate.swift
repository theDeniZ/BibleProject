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
    
    private var urlDelegate: URLDelegate?
    var urlToOpen: [String]?
    
    static private var versionKey = "currentVersion"
    
    static var context: NSManagedObjectContext {
        return AppDelegate.shared.persistentContainer.newBackgroundContext()
    }
    
    static var shared: AppDelegate {
        return NSApplication.shared.delegate as! AppDelegate
    }
    
    static var coreManager: CoreManager {
        return AppDelegate.shared.coreManager
    }
    
    static var plistManager: PlistManager {
        return AppDelegate.shared.plistManager
    }

    private lazy var coreManager: CoreManager = CoreManager(AppDelegate.context)
    private var plistManager = PlistManager()
    
    override init() {
        if !AppDelegate.isAppAlreadyLaunchedOnce {
            AppDelegate.preloadDataBase()
        } else {
            AppDelegate.versionCheck()
        }
        super.init()
    }
    
//    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
//        sharingManager.delegate = AppDelegate.shared
//    }

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
    
    static func versionCheck() {
        let defaults = UserDefaults.standard
        if let v = defaults.string(forKey: AppDelegate.versionKey),
            let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            if v < version {
                preloadDataBase()
                defaults.set(version, forKey: AppDelegate.versionKey)
            }
        } else {
            preloadDataBase()
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
    
    static let URLServerRoot = "x-com-thedeniz-bible://"
    
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
    
    private static func preloadDataBase() {
        let path = (NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true) as NSArray)[0] as! String
        let fullPath = path.appending("/macB/macB.sqlite")
        let storeURL = URL(fileURLWithPath: fullPath)

        let fileManager = Foundation.FileManager.init()
//        print(fileManager.fileExists(atPath: path))


        if fileManager.fileExists(atPath: storeURL.path) {
            let storeDirectory = storeURL.deletingLastPathComponent()
            let enumerator = fileManager.enumerator(at: storeDirectory, includingPropertiesForKeys: nil, options: .skipsHiddenFiles, errorHandler: nil)
            let storeName = String(storeURL.lastPathComponent.split(separator: ".")[0])
            for u in enumerator! {
                if let url = u as? URL {
                    if !url.lastPathComponent.hasPrefix(storeName) {
                        continue
                    }
                    try? fileManager.removeItem(at: url)
                }
            }
            // handle error
        } else {
            do {
                try fileManager.createDirectory(atPath: path + "/macB", withIntermediateDirectories: false, attributes: nil)
            } catch let error as NSError {
                print(error.localizedDescription);
            }
        }

        let bundleDbPath = Bundle.main.path(forResource: "macB", ofType: "sqlite")
        do {
            try fileManager.copyItem(atPath: bundleDbPath ?? "", toPath: storeURL.path)
            UserDefaults.standard.set(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String, forKey: AppDelegate.versionKey)
        } catch {
            print(error)
        }
        print("database is set")
//        manager.broadcastChanges()
    }

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
