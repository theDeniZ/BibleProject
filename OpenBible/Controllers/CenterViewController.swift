import UIKit

class CenterViewController: UIViewController {
    
    // MARK: - Public API
    
    var delegate: CenterViewControllerDelegate?
    var coreManager: Manager?
    var overlapped: Bool = false
    
    // MARK: - Private vars
    // MARK: Text
    var customTextView: CustomTextView! { didSet { customTextView.delegate = self }}
    var textManager: TextManager?
    private var plistManager = AppDelegate.plistManager
    var fontSize: CGFloat = 30.0 { didSet { plistManager.setFont(size: fontSize) }}
    
    // MARK: Selection
    private var firstPointOfSelection: CGPoint?
    internal var textToCopy: String?
    
    // MARK: Animation
    private var isBarsHidden = false
    private var statusBarHidden: Bool {
        get { return (UIApplication.shared.value(forKey: "statusBarWindow") as? UIWindow)?.isHidden ?? false }
        set { ( UIApplication.shared.value(forKey: "statusBarWindow") as? UIWindow)?.isHidden = newValue }
    }
    private var lastContentOffset: CGFloat = 0
    private var originalNavBarRect: CGRect?
    private var originalTabBarRect: CGRect?
    private var animationTimer: Timer?
    private var offsetKoefficient: CGFloat = 0.0
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    private var currentNavBarRect: CGRect? {
        get { return navigationController?.navigationBar.frame }
        set {
            if let rect = newValue {
                navigationController?.navigationBar.frame = rect
            } else if let org = originalNavBarRect {
                navigationController?.navigationBar.frame = org
            }
        }
    }
    private var currentTabBarRect: CGRect? {
        get { return tabBarController?.tabBar.frame }
        set {
            if let rect = newValue {
                tabBarController?.tabBar.frame = rect
            } else if let org = originalTabBarRect {
                tabBarController?.tabBar.frame = org
            }
        }
    }
    
    // MARK: - Overrides

    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.bounces = true
        scrollView.delegate = self
        fontSize = plistManager.getFontSize()
        
        loadTextManager()
        
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(scaled(sender: )))
        scrollView.addGestureRecognizer(pinch)
        
        let longTap = UILongPressGestureRecognizer(target: self, action: #selector(longTap(sender: )))
        longTap.minimumPressDuration = 0.2
        scrollView.panGestureRecognizer.require(toFail: longTap)
        scrollView.addGestureRecognizer(longTap)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(nextChapter))
        swipeLeft.direction = .left
        scrollView.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(previousChapter))
        swipeRight.direction = .right
        scrollView.addGestureRecognizer(swipeRight)
        
        let edge = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(edgeHandle(sender: )))
        edge.edges = .left
        scrollView.addGestureRecognizer(edge)
        
        originalNavBarRect = navigationController?.navigationBar.frame
        originalTabBarRect = tabBarController?.tabBar.frame
        NotificationCenter.default.addObserver(self, selector:#selector(UIMenuControllerWillHide), name:UIMenuController.willHideMenuNotification, object:nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let m = coreManager {
            navigationItem.title = "\(m.get1BookName()) \(m.chapterNumber)"
        }
        loadTextManager()
    }
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        originalNavBarRect = navigationController?.navigationBar.frame
        originalTabBarRect = tabBarController?.tabBar.frame
        loadTextManager()
        animateBars(hidden: false, instant: true)
        isBarsHidden = false
        scrollView.contentOffset.y = scrollView.contentSize.height * offsetKoefficient
    }
    
    override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        if isBarsHidden {
            isBarsHidden = false
            animateBars(hidden: isBarsHidden, instant: true)
        }
        offsetKoefficient = scrollView.contentOffset.y / scrollView.contentSize.height
        delegate?.collapseSidePanels!()
    }
    
    override var canBecomeFirstResponder: Bool { return true }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return action == #selector(CenterViewController.copySelector) ||
            action == #selector(CenterViewController.defineSelector)
    }
    
    // MARK: - Button actions
    
    @IBAction private func menuAction(_ sender: UIBarButtonItem) {
        toggleLeftMenu()
    }
    
    // MARK: - Private implementation
    
    func loadTextManager(_ forced: Bool = true) {
        var first: [NSAttributedString] = []
        var second: [NSAttributedString] = []
        let texts = coreManager?.getTwoStrings()
        if let f = texts?.0 {
            first = f
        }
        if let s = texts?.1 {
            second = s
        }
        if forced {
            textManager = TextManager(first: first, second: second)
            if let m = coreManager {
                navigationItem.title = "\(m.get1BookName()) \(m.chapterNumber)"
            }
            
            switch customTextView {
            case .some:
                customTextView.removeFromSuperview()
            default:break
            }
            
            customTextView = CustomTextView(frame: scrollView.bounds)
            customTextView.textManager = textManager
            scrollView.addSubview(customTextView)
            scrollView.scrollRectToVisible(CGRect(0, 0, 1, 1), animated:false)
        }
        textManager?.fontSize = fontSize
        customTextView.setNeedsLayout()
    }
    
    // MARK: - Selector functions
    
    func toggleLeftMenu() {
        delegate?.toggleLeftPanel!()
    }
    
    @objc private func previousChapter() {
        if !overlapped {
            coreManager?.previous()
            loadTextManager()
        } else {
            delegate?.collapseSidePanels!()
        }
    }
    
    @objc private func nextChapter() {
        if !overlapped {
            coreManager?.next()
            loadTextManager()
        } else {
            delegate?.collapseSidePanels!()
        }
    }
    
    @objc private func edgeHandle(sender: UIScreenEdgePanGestureRecognizer) {
        switch sender.state {
        case .began:
            if !overlapped {
                toggleLeftMenu()
            }
        default:break
        }
    }
    
    @objc func scaled(sender: UIPinchGestureRecognizer) {
        fontSize *= sqrt(sender.scale)
        sender.scale = 1.0
        loadTextManager(false)
    }
    
    @objc func longTap(sender: UILongPressGestureRecognizer) {
        switch sender.state {
        case .began, .changed, .possible:
            let current = sender.location(in: customTextView)
            if let p = firstPointOfSelection {
                customTextView.selectText(from: p, to: current)
            } else {
                firstPointOfSelection = current
            }
        case .ended:
            if let s = customTextView.getSelection(), let first = firstPointOfSelection {
                textToCopy = s
                becomeFirstResponder()
                let copyItem = UIMenuItem(title: "Copy".localized, action: #selector(copySelector))
                let defineItem = UIMenuItem(title: "Define".localized, action: #selector(defineSelector))
                UIMenuController.shared.menuItems = [copyItem, defineItem]
                UIMenuController.shared.setTargetRect(CGRect(first, sender.location(in: customTextView)), in:scrollView)
                UIMenuController.shared.setMenuVisible(true, animated: true)
            }
            firstPointOfSelection = nil
        case .cancelled, .failed:
            firstPointOfSelection = nil
        default:break
        }
    }
    
    @objc internal func copySelector() {
        if let text = textToCopy {
            UIPasteboard.general.string = text
            textToCopy = nil
        }
        customTextView.clearSelection()
    }
    
    @objc internal func defineSelector() {
        if let text = textToCopy {
            let txt = UITextView(frame: CGRect(x: 100, y: 100, width: 100, height: 100))
            txt.isHidden = true
            view.addSubview(txt)
            txt.text = text
            txt.isEditable = false
            txt.becomeFirstResponder()
            txt.selectedRange = NSRange(0..<text.count)
            let selector = Selector(("_define:"))
            if txt.canPerformAction(selector, withSender: nil) {
                txt.perform(selector, with: nil)
            }
            txt.removeFromSuperview()
            if isBarsHidden {
                animateBars(hidden: true, instant: true)
            }
        }
        customTextView.clearSelection()
    }
    
    @objc func UIMenuControllerWillHide() {
        customTextView.clearSelection()
    }
    
    // MARK: - Animation
    
    private func animateBars(hidden: Bool, instant: Bool = false) {
        if hidden { statusBarHidden = true }

        if !instant {
            UIView.animate(withDuration:1, delay:0, options:[.curveEaseInOut, .beginFromCurrentState], animations:{ [weak self] in
                if self?.currentNavBarRect != nil, self?.view != nil {
                    self!.currentNavBarRect = hidden ? self!.currentNavBarRect! - self!.view.frame : nil
                }
                if self?.currentTabBarRect != nil, self?.view != nil {
                    self!.currentTabBarRect = hidden ? self!.currentTabBarRect! + self!.view.frame : nil
                }
            }) { (completed) in
                if completed && !hidden {
                    self.statusBarHidden = false
                }
            }
            if currentTabBarRect != nil {
                scrollView.frame.size.height = currentTabBarRect!.origin.y
            }
            if let current = currentNavBarRect, let org = originalNavBarRect {
                if hidden {
                    animationTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: { (t) in
                        t.invalidate()
                        self.animationTimer = nil
                    })
                    scrollView.frame.origin.y = current.origin.y + current.height
                    scrollView.contentOffset.y -= org.origin.y - current.origin.y
                    lastContentOffset -= org.origin.y - current.origin.y
                    animationTimer?.invalidate()
                    animationTimer = nil
                } else {
                    animationTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { [weak self] (t) in
                        self?.scrollView.frame.origin.y = org.origin.y + org.height
                        self?.lastContentOffset += org.origin.y + org.height//self!.scrollView.contentOffset.y
                        t.invalidate()
                        self?.animationTimer = nil
                    }
                }
            }
        } else {
            if hidden {
                if let org = originalNavBarRect {
                    currentNavBarRect = org - view.frame
                }
                if let org = originalTabBarRect {
                    currentTabBarRect = org + view.frame
                }
                if currentTabBarRect != nil {
                    scrollView.frame.size.height = currentTabBarRect!.origin.y
                }
                if let current = currentNavBarRect, let org = originalNavBarRect {
                    animationTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: { (t) in
                        t.invalidate()
                        self.animationTimer = nil
                    })
                    scrollView.frame.origin.y = current.origin.y + current.height
                    scrollView.contentOffset.y -= org.origin.y - current.origin.y
                    lastContentOffset -= org.origin.y - current.origin.y
                    animationTimer?.invalidate()
                    animationTimer = nil
                }
            } else {
                currentTabBarRect = nil
                currentNavBarRect = nil
                if originalTabBarRect != nil {
                    scrollView.frame.size.height = originalTabBarRect!.origin.y - scrollView.frame.origin.y
                }
                if let org = originalNavBarRect {
                    scrollView.frame.origin.y = org.origin.y + org.height
                }
            }
        }
    }
}

// MARK: - Extensions

extension CenterViewController:SidePanelViewControllerDelegate {
    func didSelect(chapter: Int, in book: Int) {
        delegate?.collapseSidePanels?()
        coreManager?.chapterNumber = chapter
        coreManager?.bookNumber = book
        loadTextManager()
    }
    
    func setNeedsReload() {
        loadTextManager()
    }
}

extension CenterViewController:TextViewDelegate {
    func textViewDidResize(to size: CGSize) {
        scrollView.contentSize = CGSize(width: scrollView.frame.width, height: size.height)
    }
}

extension CenterViewController:UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if overlapped {
            delegate?.collapseSidePanels!()
        }
        let heightToBottom = scrollView.contentSize.height - scrollView.contentOffset.y - scrollView.frame.height
        if (self.lastContentOffset - scrollView.contentOffset.y > 0.1
//            || scrollView.contentOffset.y < 10
            || heightToBottom < 20) {
            if isBarsHidden && animationTimer == nil {
                isBarsHidden = false
                animateBars(hidden: isBarsHidden)
            }
        } else if (scrollView.contentOffset.y - self.lastContentOffset > 0.1 &&
            scrollView.contentOffset.y > 0 &&
            heightToBottom > 20) {
            if !isBarsHidden && animationTimer == nil {
                isBarsHidden = true
                animateBars(hidden: isBarsHidden)
            }
        }
        self.lastContentOffset = scrollView.contentOffset.y
    }
}
