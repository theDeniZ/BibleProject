import Cocoa

class MainWindowController: NSWindowController {
    
    @IBOutlet weak var toolbar: NSToolbar!
    
//     func leftMenuAction() {
//        if let content = contentViewController as? NSTabViewController,
//            let vc = content.children[content.selectedTabViewItemIndex] as? SpiritViewController {
//            _=vc.toggleMenu()
//        }
//    }
//
    override var acceptsFirstResponder: Bool {return true}
    
    override func windowDidLoad() {
        super.windowDidLoad()
        window?.setFrame(NSRect(x: 0, y: 0, width: 1000, height: 700), display: true)
//        setMenuImage(selected: AppDelegate.plistManager.isMenuOn())
//        let n = NSToolbarItem(itemIdentifier: .toggleSidebar)
//        toolbar.insertItem(withItemIdentifier: .toggleSidebar, at: 0)
//        becomeFirstResponder()
    }
    
    @IBAction open func toggleSidebar(_ sender: Any?) {
        if let content = contentViewController as? NSTabViewController,
            let vc = content.children[content.selectedTabViewItemIndex] as? SpiritViewController {
            _=vc.toggleMenu()
        }
    }
    
}
