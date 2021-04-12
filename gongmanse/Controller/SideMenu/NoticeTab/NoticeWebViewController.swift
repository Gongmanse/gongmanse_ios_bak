//
//  NoticeWebViewController.swift
//  gongmanse
//
//  Created by wallter on 2021/04/12.
//

import UIKit
import WebKit

class NoticeWebViewController: UIViewController {

    private let webView = WKWebView(frame: CGRect.zero)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .lightGray
        view.addSubview(webView)
        webView.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height)
        
        guard let url = URL(string: "https://www.naver.com") else { return }
        let request = URLRequest(url: url)
        webView.load(request)
        
        webView.uiDelegate = self
        webView.navigationDelegate = self
        
        // 오토레이아웃 중복되면 화면 안나옴
        self.view = self.webView
        
    }
    
}

extension NoticeWebViewController: WKUIDelegate, WKNavigationDelegate {
    
}
