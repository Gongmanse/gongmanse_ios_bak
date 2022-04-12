import UIKit
import SideMenu

public class Storage {
    static func isFirstTime() -> Bool {
        let defaults = UserDefaults.standard
        if defaults.object(forKey: "isFirstTime") == nil {
            defaults.set("No", forKey: "isFirstTime")
            return true
        } else {
            return false
        }
    }
}

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupStyle()
//        setupSideMenu()
        
        //탭 바 색상 변경
        tabBarController?.tabBar.barTintColor = UIColor.white
        if UIDevice.current.userInterfaceIdiom == .pad {
            UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 11)], for: .normal)
            UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 11)], for: .selected)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // check popup visibility
        if let noShowPopup = UserDefaults.standard.string(forKey: "popup") {
            let dateformatter: DateFormatter = DateFormatter()
            dateformatter.dateFormat = "yyyy-MM-dd"
            let calendar = Calendar.current
            let weeksAgo = calendar.date(byAdding: .day, value: -6, to: Date())!
            let weeksAgoStr = dateformatter.string(from: weeksAgo)
            
            // 일주일간 보지 않기 날짜 비교 로직 수정.
            if noShowPopup > weeksAgoStr {
                return
            }
        }
        print("performSegue popupNotice")
        performSegue(withIdentifier: "popupNotice", sender: nil)
    }
    
    func setupStyle() {
        UITabBar.clearShadow()
        tabBar.layer.applyShadow(color: .gray, alpha: 0.3, x: 0, y: 0, blur: 12)
        self.tabBar.unselectedItemTintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    }

    func setupSideMenu() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "CustomSideMenuNavigation") as! CustomSideMenuNavigation
        SideMenuManager.default.rightMenuNavigationController = vc

        // Setup gestures: the left and/or right menus must be set up (above) for these to work.
        // Note that these continue to work on the Navigation Controller independent of the view controller it displays!
        SideMenuManager.default.addScreenEdgePanGesturesToPresent(toView: self.view, forMenu: .right)
    }
}

extension CALayer {
    // Sketch 스타일의 그림자를 생성하는 유틸리티 함수
    func applyShadow(
        color: UIColor = .black,
        alpha: Float = 0.5,
        x: CGFloat = 0,
        y: CGFloat = 2,
        blur: CGFloat = 4
    ) {
        shadowColor = color.cgColor
        shadowOpacity = alpha
        shadowOffset = CGSize(width: x, height: y)
        shadowRadius = blur / 2.0
    }
}

extension UITabBar {
    // 기본 그림자 스타일을 초기화해야 커스텀 스타일을 적용
    static func clearShadow() {
        UITabBar.appearance().shadowImage = UIImage()
        UITabBar.appearance().backgroundImage = UIImage()
        UITabBar.appearance().backgroundColor = UIColor.white
    }
}
