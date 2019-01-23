import Cocoa

class MainWindowController: NSWindowController {
    
    @IBOutlet weak var menuItem: NSToolbarItem!
    
    @IBAction func leftMenuAction(_ sender: NSToolbarItem) {
        if let content = contentViewController as? NSTabViewController,
            let vc = content.children[content.selectedTabViewItemIndex] as? SpiritViewController {
            setMenuImage(selected: vc.toggleMenu())
        }
    }
    
    func setMenuImage(selected: Bool) {
        if selected {
            menuItem.image = NSImage.init(imageLiteralResourceName: "menuSelected")
        } else {
            menuItem.image = NSImage.init(imageLiteralResourceName: "menu")
        }
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        window?.setFrame(NSRect(x: 0, y: 0, width: 1000, height: 700), display: true)
        setMenuImage(selected: AppDelegate.plistManager.isMenuOn())
    }
    
}
