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
    private var activityIndicator = UIActivityIndicatorView()
    
    // ID 받아옴
    var noticeID = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(webView)
        view.addSubview(activityIndicator)
        activityIndicator.center = view.center
        activityIndicator.style = .medium
        
        // 공지사항 웹뷰 URL 
        let noticeViewUrl = "/notices/view/"
        guard let url = URL(string: webBaseURL+noticeViewUrl+noticeID) else { return }
        let request = URLRequest(url: url)
        webView.load(request)
        
        webViewConfiguration()
        
    }
    
}
// MARK: - WebView 설정관련

extension NoticeWebViewController {
    
    func webViewConfiguration() {
        
        self.activityIndicator.startAnimating()
        webView.uiDelegate = self
        webView.navigationDelegate = self
        self.activityIndicator.hidesWhenStopped = true
        
        // WebView 스크롤시 Indicator, bounce false
        webView.scrollView.showsVerticalScrollIndicator = false
        webView.scrollView.showsHorizontalScrollIndicator = false
        webView.scrollView.alwaysBounceHorizontal = false
        webView.scrollView.alwaysBounceVertical = false
        
        // WebView 오토레이아웃
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        webView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        webView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        webView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
    }
}

// MARK: - WebView delegate

extension NoticeWebViewController: WKUIDelegate, WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        activityIndicator.stopAnimating()
    }
    
    private func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        
        activityIndicator.stopAnimating()
    }
}
