import UIKit
import QuartzCore

class ContainerViewController: UIViewController {
  
  enum SlideOutState {
    case collapsed
    case leftPanelExpanded
  }
  
    var manager: VerseManager? = VerseManager(in: AppDelegate.context)
    
  var centerNavigationController: UINavigationController!
  var centerViewController: CenterVersesViewController!
  
  var currentState: SlideOutState = .collapsed {
    didSet {
      let shouldShowShadow = currentState != .collapsed
      showShadowForCenterViewController(shouldShowShadow)
    }
  }
  var leftViewController: LeftSelectionViewController?
  
  let centerPanelExpandedOffset: CGFloat = 60
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    centerViewController = UIStoryboard.centerViewController()
    centerViewController.delegate = self
    centerViewController.verseManager = manager
    
    centerNavigationController = UINavigationController(rootViewController: centerViewController)
    view.addSubview(centerNavigationController.view)
    addChild(centerNavigationController)
    
    centerNavigationController.didMove(toParent: self)
    
  }
}

// MARK: CenterViewController delegate
extension ContainerViewController:CenterViewControllerDelegate {
  
  func toggleLeftPanel() {
    
    let notAlreadyExpanded = (currentState != .leftPanelExpanded)
    
    if notAlreadyExpanded {
      addLeftPanelViewController()
    }
    
    animateLeftPanel(shouldExpand: notAlreadyExpanded)
  }

  
  func collapseSidePanels() {
    if currentState == .leftPanelExpanded {
      toggleLeftPanel()
    }
  }
  
  func addLeftPanelViewController() {
    
    guard leftViewController == nil else { return }
    
    if let vc = UIStoryboard.leftViewController() {
      
      addChildSidePanelController(vc)
      leftViewController = vc
        vc.rightSpace = centerPanelExpandedOffset
        vc.manager = manager
    }
  }
  
  func addChildSidePanelController(_ sidePanelController: SidePanelViewController) {
    
    sidePanelController.delegate = centerViewController
    view.insertSubview(sidePanelController.view, at: 0)
    
    addChild(sidePanelController)
    sidePanelController.didMove(toParent: self)
  }
  
  func animateLeftPanel(shouldExpand: Bool) {
    
    if shouldExpand {
      currentState = .leftPanelExpanded
      animateCenterPanelXPosition(targetPosition: centerNavigationController.view.frame.width - centerPanelExpandedOffset)
      
    } else {
      animateCenterPanelXPosition(targetPosition: 0) { _ in
        self.currentState = .collapsed
        self.leftViewController?.view.removeFromSuperview()
        self.leftViewController = nil
      }
    }
  }
  
  func animateCenterPanelXPosition(targetPosition: CGFloat, completion: ((Bool) -> Void)? = nil) {
    
    UIView.animate(withDuration:0.5, delay:0, usingSpringWithDamping:0.8, initialSpringVelocity:0, options:.curveEaseInOut, animations:{
      self.centerNavigationController.view.frame.origin.x = targetPosition
    }, completion: completion)
  }
  
  func showShadowForCenterViewController(_ shouldShowShadow: Bool) {
    if shouldShowShadow {
      centerNavigationController.view.layer.shadowOpacity = 0.8
        centerViewController.overlapped = true
    } else {
      centerNavigationController.view.layer.shadowOpacity = 0.0
        centerViewController.overlapped = false
    }
  }
}

extension UIStoryboard {
  
  static func main() -> UIStoryboard { return UIStoryboard(name: "Main", bundle: Bundle.main) }
  
  static func leftViewController() -> LeftSelectionViewController? {
    return main().instantiateViewController(withIdentifier: "LeftViewController") as? LeftSelectionViewController
  }
  
  static func centerViewController() -> CenterVersesViewController? {
    return main().instantiateViewController(withIdentifier: "CenterViewController") as? CenterVersesViewController
  }
  
  static func StartViewController() -> UIViewController? {
    return main().instantiateViewController(withIdentifier: "Start")
  }
}
