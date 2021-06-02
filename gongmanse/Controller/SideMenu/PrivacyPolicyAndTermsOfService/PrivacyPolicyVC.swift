import UIKit
import WebKit

class PrivacyPolicyVC: UIViewController, WKUIDelegate, WKNavigationDelegate {

    @IBOutlet weak var webView: WKWebView!
    
    private let backButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: "chevron.backward.circle")
        button.tintColor = .darkGray
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(backButtonDidTap), for: .touchUpInside)
        return button
    }()
    
    
    override func loadView() {
        super.loadView()
        
        webView.backgroundColor = .clear
        webView.uiDelegate = self
        webView.navigationDelegate = self
//        self.view = self.webView
    }
    
    @objc func backButtonDidTap() {
        
        dismiss(animated: true)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //네비게이션 바 타이틀 지정
        self.navigationItem.title = "개인정보 처리방침"
        
        //네비게이션 바 뒤로가기 버튼 색상 바꾸기
        self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 0.1098039216, green: 0.1098039216, blue: 0.1098039216, alpha: 1)
        
        //네비게이션 바 뒤로가기 버튼 타이틀 없애기
        self.navigationController?.navigationBar.topItem?.title = ""
        
        view.backgroundColor = .white
        let url = URL(string: "https://webview.gongmanse.com/users/privacy_policy")
        let request = URLRequest(url: url!)
        self.webView.allowsBackForwardNavigationGestures = true
        webView.configuration.preferences.javaScriptEnabled = true
        webView.load(request)
        
        view.addSubview(backButton)
        backButton.setDimensions(height: 30,
                                 width: 30)
        backButton.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                          left: view.leftAnchor,
                          paddingLeft: 20)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
