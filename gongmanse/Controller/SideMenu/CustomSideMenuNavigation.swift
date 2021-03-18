import UIKit
import SideMenu

class CustomSideMenuNavigation: SideMenuNavigationController, SideMenuNavigationControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.presentationStyle = .menuSlideIn
        self.menuWidth = self.view.frame.width * 0.8
        self.presentationStyle.backgroundColor = .black
        self.presentationStyle.presentingEndAlpha = 0.5
        self.statusBarEndAlpha = 0.0
    }
}
