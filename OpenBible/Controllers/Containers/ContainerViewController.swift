import UIKit
import QuartzCore

class ContainerViewController: UIViewController, Storyboarded, MenuDelegate {
  
  enum SlideOutState {
    case collapsed
    case leftPanelExpanded
  }
    
    weak var coordinator: ContainerCoordinator!
    
    private var maximumWidthOfTheLeftPanel: CGFloat {
        return UIDevice.current.userInterfaceIdiom == .phone ? 500.0 : 300.0
    }
    
    var centerNavigationController: UINavigationController {
        return coordinator.navigationController
    }

  
  var currentState: SlideOutState = .collapsed {
    didSet {
      let shouldShowShadow = currentState != .collapsed
      showShadowForCenterViewController(shouldShowShadow)
    }
  }
  
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
    
    
//    centerNavigationController = coordinator.getRootController()//UIStoryboard.centerViewController()//UINavigationController(rootViewController: centerViewController)
    
    
//    centerViewController?.delegate = self
    initialise()
  }
    
    func initialise() {
//        guard let centerCoordinator = centerCoordinator else {return}
//        coordinator.start()
//        coordinator.menuDelegate = self
//        if let nav = centerNavigationController {
            view.addSubview(centerNavigationController.view)
            addChild(centerNavigationController)
            centerNavigationController.didMove(toParent: self)
//        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        collapseMenu()
    }
    
}

// MARK: CenterViewController delegate
extension ContainerViewController {
  
  func toggleMenu() {
    
    let notAlreadyExpanded = (currentState != .leftPanelExpanded)
    
    if notAlreadyExpanded {
      addLeftPanelViewController()
    }
    
    animateLeftPanel(shouldExpand: notAlreadyExpanded)
  }

  
  func collapseMenu() {
    if currentState == .leftPanelExpanded {
      toggleMenu()
    }
  }
  
  private func addLeftPanelViewController() {
    
//    guard leftCoordinator == nil else { return }
    
    if let menu = coordinator.menuCoordinator {
        menu.start()
      let vc = menu.rootViewController
      addChildSidePanelController(vc)
      vc.rightSpace = centerPanelExpandedOffset
    }
//    leftCoordinator = menu
  }
  
  private func addChildSidePanelController(_ sidePanelController: LeftSelectionViewController) {
    view.insertSubview(sidePanelController.view, at: 0)
    addChild(sidePanelController)
    sidePanelController.didMove(toParent: self)
  }
  
  private func animateLeftPanel(shouldExpand: Bool) {
//    guard let centerNavigationController = centerNavigationController else {return}
    if shouldExpand {
      currentState = .leftPanelExpanded
      animateCenterPanelXPosition(targetPosition: centerNavigationController.view.frame.width - centerPanelExpandedOffset)
      
    } else {
      animateCenterPanelXPosition(targetPosition: 0) { _ in
        self.currentState = .collapsed
        self.coordinator.menuCoordinator?.rootViewController.view.removeFromSuperview()
        self.coordinator.menuCoordinator = nil
      }
    }
  }
  
  private func animateCenterPanelXPosition(targetPosition: CGFloat, completion: ((Bool) -> Void)? = nil) {
//    guard let centerNavigationController = centerNavigationController else {return}
    UIView.animate(withDuration:0.5, delay:0, usingSpringWithDamping:0.8, initialSpringVelocity:0, options:.curveEaseInOut, animations:{
      self.centerNavigationController.view.frame.origin.x = targetPosition
    }, completion: completion)
  }
  
  private func showShadowForCenterViewController(_ shouldShowShadow: Bool) {
//    guard let centerNavigationController = centerNavigationController else {return}
    if shouldShowShadow {
      centerNavigationController.view.layer.shadowOpacity = 0.8
//        centerViewController?.overlapped = true
    } else {
      centerNavigationController.view.layer.shadowOpacity = 0.0
//        centerViewController?.overlapped = false
    }
  }
}

extension UIStoryboard {
  static func main() -> UIStoryboard { return UIStoryboard(name: "Main", bundle: Bundle.main) }
}
