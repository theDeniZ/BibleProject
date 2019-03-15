import UIKit
import QuartzCore

class ContainerViewController: UIViewController {
  
  enum SlideOutState {
    case collapsed
    case leftPanelExpanded
  }
  
    private var maximumWidthOfTheLeftPanel: CGFloat {
        return UIDevice.current.userInterfaceIdiom == .phone ? 500.0 : 300.0
    }
    
  var centerNavigationController: UINavigationController!
    var centerViewController: ContainingViewController? {
        get {
            return centerNavigationController.visibleViewController as? ContainingViewController
        }
    }
  
  var currentState: SlideOutState = .collapsed {
    didSet {
      let shouldShowShadow = currentState != .collapsed
      showShadowForCenterViewController(shouldShowShadow)
    }
  }
  var leftViewController: LeftSelectionViewController?
  
    /// The amount of space the main screen is still visible on
    /// is NOT the width of left panel
    var centerPanelExpandedOffset: CGFloat {
        switch UIDevice.current.orientation {
        case .landscapeLeft, .landscapeRight:
            return max(view.bounds.width / 2.0, view.bounds.width - maximumWidthOfTheLeftPanel)
        default:
            return max(view.bounds.width / 5.0, view.bounds.width - maximumWidthOfTheLeftPanel)
        }
    }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
//    centerViewController =
    
    
    centerNavigationController = UIStoryboard.centerViewController()//UINavigationController(rootViewController: centerViewController)
    view.addSubview(centerNavigationController.view)
    addChild(centerNavigationController)
    
    centerNavigationController.didMove(toParent: self)
    
    centerViewController?.delegate = self
    
  }
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        collapseSidePanels()
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
        centerViewController?.overlapped = true
    } else {
      centerNavigationController.view.layer.shadowOpacity = 0.0
        centerViewController?.overlapped = false
    }
  }
}

extension UIStoryboard {
  
  static func main() -> UIStoryboard { return UIStoryboard(name: "Main", bundle: Bundle.main) }
  
  static func leftViewController() -> LeftSelectionViewController? {
    return main().instantiateViewController(withIdentifier: "LeftViewController") as? LeftSelectionViewController
  }
  
  static func centerViewController() -> UINavigationController? {
    return main().instantiateViewController(withIdentifier: "CenterViewController") as? UINavigationController
  }
  
  static func StartViewController() -> UIViewController? {
    return main().instantiateViewController(withIdentifier: "Start")
  }
}
