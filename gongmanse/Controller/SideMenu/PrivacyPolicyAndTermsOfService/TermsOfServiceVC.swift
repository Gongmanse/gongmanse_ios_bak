import UIKit
import WebKit

class TermsOfServiceVC: UIViewController, WKUIDelegate, WKNavigationDelegate {
    
    // MARK: - Property
    
    @IBOutlet weak var webView: WKWebView!
    
    private let backButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: "chevron.backward.circle")
        button.setImage(image, for: .normal)
        button.tintColor = .darkGray
        button.addTarget(self, action: #selector(backButtonDidTap), for: .touchUpInside)
        return button
    }()

    
    // MARK: - Lifecycle
    
    override func loadView() {
        super.loadView()
        
        webView.backgroundColor = .clear
        webView.uiDelegate = self
        webView.navigationDelegate = self
//        self.view = self.webView
    }
    
    
    // MARK: - Action
    
    @objc func backButtonDidTap() {
        
        dismiss(animated: true)
    }
    
    
    // MARK: - Helepr
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //네비게이션 바 타이틀 지정
        self.navigationItem.title = "이용 약관"
        
        //네비게이션 바 뒤로가기 버튼 색상 바꾸기
        self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 0.1098039216, green: 0.1098039216, blue: 0.1098039216, alpha: 1)
        
        //네비게이션 바 뒤로가기 버튼 타이틀 없애기
        self.navigationController?.navigationBar.topItem?.title = ""
        
        view.backgroundColor = .white
        let url = URL(string: "https://webview.gongmanse.com/users/toa_read")
        let request = URLRequest(url: url!)
        self.webView.allowsBackForwardNavigationGestures = true
        webView.load(request)
        
        
        view.addSubview(backButton)
        backButton.setDimensions(height: 30,
                                 width: 30)
        backButton.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                          left: view.leftAnchor,
                          paddingLeft: 20)
    }
}
