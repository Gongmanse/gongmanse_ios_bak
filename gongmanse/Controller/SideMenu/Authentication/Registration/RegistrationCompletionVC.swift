//
//  RegistrationCompletionVC.swift
//  gongmanse
//
//  Created by 김우성 on 2021/03/22.
//

import UIKit

class RegistrationCompletionVC: UIViewController {

    // MARK: - Properties
    
    
    // MARK: - IBOutlet
    // 오토레이아웃 - CODE
    
    @IBOutlet weak var currentProgressView: UIView!
    @IBOutlet weak var totalProgressView: UIView!
    @IBOutlet weak var pageID: UILabel!
    @IBOutlet weak var pageNumber: UILabel!
    
    
    
    @IBOutlet weak var completeImage: UIImageView!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var completeMent01: UILabel!
    @IBOutlet weak var completeMent02: UILabel!
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        cofigureNavi()
 
     
    }

    // MARK: - Actions

    @IBAction func backToMainPage(_ sender: Any) {
        tabBarController?.tabBar.isHidden = false
        self.navigationController?.popToRootViewController(animated: true)
        
    }
    
    // MARK: - Helper functions

    func configureUI() {
        tabBarController?.tabBar.isHidden = true
        
        nextButton.backgroundColor = UIColor.mainOrange
        nextButton.layer.cornerRadius = 10
        nextButton.addShadow()
        
        // ProgressView 오토레이아웃
        totalProgressView.centerX(inView: view)
        totalProgressView.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                                 left: view.leftAnchor,
                                 right: view.rightAnchor,
                                 height: 4)
        totalProgressView.backgroundColor = UIColor.mainOrange
        
        currentProgressView.setDimensions(height: 4, width: view.frame.width * 1.0)
        currentProgressView.anchor(top:totalProgressView.topAnchor,
                                   left: totalProgressView.leftAnchor)
        currentProgressView.backgroundColor = .mainOrange
        
        pageID.setDimensions(height: view.frame.height * 0.02,
                             width: view.frame.width * 0.15)
        pageID.anchor(top: totalProgressView.bottomAnchor,
                      left: totalProgressView.leftAnchor,
                      paddingTop: 11,
                      paddingLeft: 20)
        pageID.font = UIFont.appBoldFontWith(size: 14)
        pageID.textAlignment = .left
        
        pageNumber.setDimensions(height: view.frame.height * 0.02,
                                 width: view.frame.width * 0.15)
        pageNumber.anchor(top: totalProgressView.bottomAnchor,
                          right: view.rightAnchor,
                          paddingTop: 11,
                          paddingRight: 20)
        pageNumber.font = UIFont.appBoldFontWith(size: 14)
        pageNumber.textAlignment = .right
        
        // completeMent01
        // 한 줄의 텍스트에 다르게 속성을 설정하는 코드 "NSMutableAttributedString"
        let attributedString = NSMutableAttributedString(string: "회원가입",
                                                         attributes: [NSAttributedString.Key.foregroundColor: UIColor.mainOrange])
        
        attributedString.append(NSAttributedString(string: "이 완료되었습니다.",
                                                   attributes: [NSAttributedString.Key.foregroundColor: UIColor.black]))
        completeMent01.attributedText = attributedString
        completeMent01.font = UIFont.appEBFontWith(size: 22)
        completeMent02.font = UIFont.appBoldFontWith(size: 13)
        
    }
    
    func cofigureNavi() {
        // 내비게이션 타이틀 폰트 변경
        let title = UILabel()
        title.text = "회원가입"
        title.font = UIFont.appBoldFontWith(size: 17)
        navigationItem.titleView = title
    }

}

