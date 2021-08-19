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
    var noticeAlert = false
    var eventAlert = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationSetting()
        
        view.addSubview(webView)
        view.addSubview(activityIndicator)
        activityIndicator.center = view.center
        activityIndicator.style = .medium
        
        // 공지사항 웹뷰 URL
        if noticeAlert {
            let noticeViewUrl = "/notices/view/"
            guard let url = URL(string: webBaseURL+noticeViewUrl+noticeID) else { return }
            let request = URLRequest(url: url)
            webView.load(request)
            
            noticeAlert = false
        }
        
        if eventAlert {
            let noticeViewUrl = "/events/view/"
            guard let url = URL(string: webBaseURL+noticeViewUrl+noticeID) else { return }
            let request = URLRequest(url: url)
            webView.load(request)

            eventAlert = false
        }
                
        webViewConfiguration()
        
    }
    
    func navigationSetting() {
        
        //네비게이션 바 타이틀 정하기
        self.navigationItem.title = "공지사항"
        
        //네비게이션 바 뒤로가기 버튼 색상 바꾸기
        self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 0.1098039216, green: 0.1098039216, blue: 0.1098039216, alpha: 1)
        
        //네비게이션 바 뒤로가기 버튼 타이틀 없애기
        self.navigationController?.navigationBar.topItem?.title = ""
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
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        activityIndicator.stopAnimating()
    }
}
