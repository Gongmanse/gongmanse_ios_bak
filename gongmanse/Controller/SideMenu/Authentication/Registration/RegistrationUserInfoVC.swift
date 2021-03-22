//
//  RegistrationUserInfoVC.swift
//  gongmanse
//
//  Created by 김우성 on 2021/03/22.
//

import UIKit

class RegistrationUserInfoVC: UIViewController {

    // MARK: - Properties
    

    
    // MARK: - IBOutlet
    // 오토레이아웃 - CODE
    @IBOutlet weak var currentProgressView: UIView!
    @IBOutlet weak var totalProgressView: UIView!
    @IBOutlet weak var pageID: UILabel!
    @IBOutlet weak var pageNumber: UILabel!
    @IBOutlet weak var idTextField: SloyTextField!
    
    
    
    @IBOutlet weak var nextButton: UIButton!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        cofigureNavi()
 
     
    }

    // MARK: - Actions
    
    @IBAction func handleNextPage(_ sender: Any) {
        self.navigationController?.pushViewController(CheckUserIdentificationVC(), animated: false)
    }
    
    // MARK: - Helper functions

    func configureUI() {
        tabBarController?.tabBar.isHidden = true
        
        nextButton.backgroundColor = UIColor.mainOrange
        nextButton.layer.cornerRadius = 10
        
        // ProgressView 오토레이아웃
        totalProgressView.centerX(inView: view)
        totalProgressView.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                                 left: view.leftAnchor,
                                 right: view.rightAnchor,
                                 height: 4)
        totalProgressView.backgroundColor = UIColor(white: 200.0 / 255.0, alpha: 1.0)
        
        currentProgressView.setDimensions(height: 4, width: view.frame.width * 0.5)
        currentProgressView.anchor(top:totalProgressView.topAnchor,
                                   left: totalProgressView.leftAnchor)
        currentProgressView.backgroundColor = .mainOrange
        
        // 정보기입
        pageID.setDimensions(height: view.frame.height * 0.02,
                             width: view.frame.width * 0.15)
        pageID.anchor(top: totalProgressView.bottomAnchor,
                      left: totalProgressView.leftAnchor,
                      paddingTop: 11,
                      paddingLeft: 20)
        pageID.font = UIFont.appBoldFontWith(size: 14)
        pageID.textAlignment = .left
        
        // 2/4
        pageNumber.setDimensions(height: view.frame.height * 0.02,
                                 width: view.frame.width * 0.15)
        pageNumber.anchor(top: totalProgressView.bottomAnchor,
                          right: view.rightAnchor,
                          paddingTop: 11,
                          paddingRight: 20)
        pageNumber.font = UIFont.appBoldFontWith(size: 14)
        pageNumber.textAlignment = .right
        
        // 아이디 TextField
        // 아이디 TextField leftView
        let tfWidth = view.frame.width - 40
        let idImage = #imageLiteral(resourceName: "myActivity")
        let idleftView = UIView(frame: CGRect(x: 0, y: 10, width: 20, height: 20))
        let idimageView = UIImageView(frame: CGRect(x: 0, y: 10, width: 20, height: 20))
        idimageView.image = idImage
        idleftView.addSubview(idimageView)
        
        idTextField.setDimensions(height: 50, width: tfWidth - 20)
        idTextField.placeholder = "아이디"
        idTextField.leftViewMode = .always
        idTextField.leftView = idleftView
        idTextField.keyboardType = .emailAddress
        idTextField.centerX(inView: view)
        idTextField.anchor(top: totalProgressView.bottomAnchor,
                           paddingTop: view.frame.height * 0.1)
    }
    
    func cofigureNavi() {
        // 내비게이션 타이틀 폰트 변경
        let title = UILabel()
        title.text = "회원가입"
        title.font = UIFont.appBoldFontWith(size: 17)
        navigationItem.titleView = title
    }

}


// MARK: - UITextField LeftView

private extension RegistrationUserInfoVC {
    
}
