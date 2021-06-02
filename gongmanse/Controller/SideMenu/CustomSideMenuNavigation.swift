import UIKit
import SideMenu

class CustomSideMenuNavigation: SideMenuNavigationController, SideMenuNavigationControllerDelegate {
    
    // MARK: - Properties
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
    }
    
    // MARK: - Actions
    
    @objc func showTermsOfService() {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "TermsOfServiceVC") as! TermsOfServiceVC
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    @objc func showPrivacyPolicy() {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "PrivacyPolicyVC") as! PrivacyPolicyVC
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    // MARK: - Heleprs
    
    func setupLayout() {
        
        self.presentationStyle = .menuSlideIn
        self.menuWidth = self.view.frame.width * 0.8
        self.presentationStyle.backgroundColor = .black
        self.presentationStyle.presentingEndAlpha = 0.5
        self.statusBarEndAlpha = 0.0

        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: menuWidth, height: 30))
        view.addSubview(footerView)
        footerView.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor,
                          right: view.rightAnchor,
                          width: menuWidth,
                          height: 30)
        footerView.isUserInteractionEnabled = true
        let termsOfServiceBtn = UIButton(frame: CGRect(x: 0, y: 310, width: menuWidth / 2, height: 30))
        let privacyPolicyBtn = UIButton(frame: CGRect(x: 157, y: 310, width: menuWidth / 2, height: 30))
        
        termsOfServiceBtn.setTitle("이용약관", for: .normal)
        termsOfServiceBtn.backgroundColor = .systemGray4
        termsOfServiceBtn.setTitleColor(.gray, for: .normal)
        termsOfServiceBtn.titleLabel?.font = UIFont.appRegularFontWith(size: 14)
        termsOfServiceBtn.addTarget(self, action: #selector(showTermsOfService), for: .touchUpInside)
        footerView.addSubview(termsOfServiceBtn)
        termsOfServiceBtn.anchor(top: footerView.topAnchor,
                                 left: footerView.leftAnchor)
        termsOfServiceBtn.setDimensions(height: footerView.frame.height,
                                        width: footerView.frame.width * 0.5)
        
        privacyPolicyBtn.setTitle("개인정보처리방침", for: .normal)
        privacyPolicyBtn.backgroundColor = .systemGray4
        privacyPolicyBtn.setTitleColor(.gray, for: .normal)
        privacyPolicyBtn.titleLabel?.font = UIFont.appRegularFontWith(size: 14)
        privacyPolicyBtn.addTarget(self, action: #selector(showPrivacyPolicy), for: .touchUpInside)
        footerView.addSubview(privacyPolicyBtn)
        privacyPolicyBtn.anchor(top: footerView.topAnchor,
                                 right: footerView.rightAnchor)
        privacyPolicyBtn.setDimensions(height: footerView.frame.height,
                                        width: footerView.frame.width * 0.5)
        
        let versionLabel = UILabel()
        versionLabel.text = "버전 2.0.4"
        versionLabel.font = UIFont.appBoldFontWith(size: 12)
        versionLabel.textColor = .gray
        versionLabel.backgroundColor = .white
        
        view.addSubview(versionLabel)
        versionLabel.centerX(inView: footerView)
        versionLabel.anchor(bottom: footerView.topAnchor,
                            height: 30)
        
        termsOfServiceBtn.translatesAutoresizingMaskIntoConstraints = false
    }
    
}
