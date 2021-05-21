import UIKit
import WebKit

class TermsOfServiceVC: UIViewController, WKUIDelegate, WKNavigationDelegate {

    @IBOutlet weak var webView: WKWebView!
    
    override func loadView() {
        super.loadView()
        
        webView.backgroundColor = .clear
        webView.uiDelegate = self
        webView.navigationDelegate = self
        self.view = self.webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let url = URL(string: "https://webview.gongmanse.com/users/toa_read")
        let request = URLRequest(url: url!)
        self.webView.allowsBackForwardNavigationGestures = true
        webView.load(request)
    }
}
