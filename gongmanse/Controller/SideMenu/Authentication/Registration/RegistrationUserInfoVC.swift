//
//  RegistrationUserInfoVC.swift
//  gongmanse
//
//  Created by 김우성 on 2021/03/22.
//

import UIKit

class RegistrationUserInfoVC: UIViewController {

    // MARK: - Properties
    
    var userInfo = RegistrationInput(username: "", password: "", confirm_password: "", first_name: "", nickname: "", phone_number: 0, verification_code: 0, email: "", address1: "", address2: "", city: "", zip: 0, country: "")
    
    // MARK: - IBOutlet
    // 오토레이아웃 - CODE
    @IBOutlet weak var currentProgressView: UIView!
    @IBOutlet weak var totalProgressView: UIView!
    @IBOutlet weak var pageID: UILabel!
    @IBOutlet weak var pageNumber: UILabel!
    
    // textField
    @IBOutlet weak var idTextField: SloyTextField!
    @IBOutlet weak var pwdTextField: SloyTextField!
    @IBOutlet weak var confirmPwdTextField: SloyTextField!
    @IBOutlet weak var nameTextField: SloyTextField!
    @IBOutlet weak var nicknameTextField: SloyTextField!
    @IBOutlet weak var emailTextField: SloyTextField!
    
    
    
    @IBOutlet weak var nextButton: UIButton!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        cofigureNavi()
        
     
    }

    // MARK: - Actions
    
    @IBAction func handleNextPage(_ sender: Any) {
        let vc = CheckUserIdentificationVC()
        // "회원정보" 페이지에서 작성한 값들을 화면전환 전에 넘겨줌
        vc.userInfoData = self.userInfo
        self.navigationController?.pushViewController(vc, animated: false)
    }
    
    // MARK: - Helper functions

    func configureUI() {
        idTextField.delegate = self
        pwdTextField.delegate = self
        confirmPwdTextField.delegate = self
        nameTextField.delegate = self
        nicknameTextField.delegate = self
        emailTextField.delegate = self
        
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
        
        // MARK: TextField Setting
        // 아이디 TextField
        // 아이디 TextField leftView
        let tfWidth = view.frame.width - 125
        
        let idTfLeftView = settingLeftViewInTextField(idTextField, #imageLiteral(resourceName: "myActivity"))
        idTextField.setDimensions(height: 50, width: tfWidth)
        idTextField.placeholder = "아이디"
        idTextField.leftViewMode = .always
        idTextField.leftView = idTfLeftView
        idTextField.keyboardType = .emailAddress
        idTextField.centerX(inView: view)
        idTextField.anchor(top: totalProgressView.bottomAnchor,
                           paddingTop: view.frame.height * 0.05)
        
        // 비밀번호 TextField
        let pwdTfLeftView = settingLeftViewInTextField(idTextField, #imageLiteral(resourceName: "myActivity"))
        pwdTextField.setDimensions(height: 50, width: tfWidth)
        pwdTextField.placeholder = "비밀번호"
        pwdTextField.leftViewMode = .always
        pwdTextField.leftView = pwdTfLeftView
        pwdTextField.keyboardType = .emailAddress
        pwdTextField.isSecureTextEntry = true
        pwdTextField.centerX(inView: view)
        pwdTextField.anchor(top: idTextField.bottomAnchor,
                           paddingTop: view.frame.height * 0.03)
        
        // 비밀번호 재입력 TextField
        let confirmPwdTfLeftView = settingLeftViewInTextField(idTextField, #imageLiteral(resourceName: "myActivity"))
        confirmPwdTextField.setDimensions(height: 50, width: tfWidth)
        confirmPwdTextField.placeholder = "비밀번호 재입력"
        confirmPwdTextField.leftViewMode = .always
        confirmPwdTextField.leftView = confirmPwdTfLeftView
        confirmPwdTextField.keyboardType = .emailAddress
        confirmPwdTextField.isSecureTextEntry = true
        confirmPwdTextField.centerX(inView: view)
        confirmPwdTextField.anchor(top: pwdTextField.bottomAnchor,
                           paddingTop: view.frame.height * 0.03)
        
        // 이름 TextField
        let nameTfLeftView = settingLeftViewInTextField(idTextField, #imageLiteral(resourceName: "myActivity"))
        nameTextField.setDimensions(height: 50, width: tfWidth)
        nameTextField.placeholder = "이름"
        nameTextField.leftViewMode = .always
        nameTextField.leftView = nameTfLeftView
        nameTextField.keyboardType = .emailAddress
        nameTextField.centerX(inView: view)
        nameTextField.anchor(top: confirmPwdTextField.bottomAnchor,
                           paddingTop: view.frame.height * 0.03)
        
        // 닉네임 TextField
        let nicknameLeftView = settingLeftViewInTextField(idTextField, #imageLiteral(resourceName: "myActivity"))
        nicknameTextField.setDimensions(height: 50, width: tfWidth)
        nicknameTextField.placeholder = "닉네임"
        nicknameTextField.leftViewMode = .always
        nicknameTextField.leftView = nicknameLeftView
        nicknameTextField.keyboardType = .emailAddress
        nicknameTextField.centerX(inView: view)
        nicknameTextField.anchor(top: nameTextField.bottomAnchor,
                           paddingTop: view.frame.height * 0.03)
        
        // 이메일 TextField
        let emailLeftView = settingLeftViewInTextField(idTextField, #imageLiteral(resourceName: "myActivity"))
        emailTextField.setDimensions(height: 50, width: tfWidth)
        emailTextField.placeholder = "이메일"
        emailTextField.leftViewMode = .always
        emailTextField.leftView = emailLeftView
        emailTextField.keyboardType = .emailAddress
        emailTextField.centerX(inView: view)
        emailTextField.anchor(top: nicknameTextField.bottomAnchor,
                           paddingTop: view.frame.height * 0.03)
        
    }
    
    func cofigureNavi() {
        // 내비게이션 타이틀 폰트 변경
        let title = UILabel()
        title.text = "회원가입"
        title.font = UIFont.appBoldFontWith(size: 17)
        navigationItem.titleView = title
    }

}


// MARK: - UITextFieldDelegate

extension RegistrationUserInfoVC: UITextFieldDelegate {
    
    // UITextField가 수정이 시작될 때, 호출
    func textFieldDidBeginEditing(_ textField: UITextField) {
    }
    
    // UITextField가 수정이 완료될 때, 호출
    func textFieldDidEndEditing(_ textField: UITextField) {
    }
    
    // UITextField 사용중에 키보드에서 return(엔터나 완료버튼)을 클릭 시, 호출
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let tf = textField as! SloyTextField
        
        switch tf {
        case idTextField:
            self.userInfo.username = idTextField.text!
        case pwdTextField:
            self.userInfo.password = pwdTextField.text!
        case confirmPwdTextField:
            self.userInfo.confirm_password = confirmPwdTextField.text!
        case nameTextField:
            self.userInfo.first_name = nameTextField.text!
        case nicknameTextField:
            self.userInfo.nickname = nicknameTextField.text!
        case emailTextField:
            self.userInfo.email = emailTextField.text!
        default:
            print("DEBUG: didn't find textField in Registration...")
        }
        return true
    }
    
}
