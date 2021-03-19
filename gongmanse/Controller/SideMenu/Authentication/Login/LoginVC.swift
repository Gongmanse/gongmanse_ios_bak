//
//  LoginVC.swift
//  gongmanse
//
//  Created by 김우성 on 2021/03/19.
//

import UIKit

class LoginVC: UIViewController {

    // MARK: - Test - UITextField 03.19 14:21
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    
    
    
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var idTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var findingIDButton: UIButton!
    @IBOutlet weak var findingPasswordButton: UIButton!
    @IBOutlet weak var registrationButton: UIButton!
    
    // 비밀번호 찾기 좌측 구분선
    let leftDividerView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    // 비밀번호 찾기 우측 구분선
    let rightDividerView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        setupUI()
        // UI 메모리 로드 이후, 내비게이션 바와 탭 바 제거
        navigationController?.navigationBar.isHidden = true
        tabBarController?.tabBar.isHidden = true
    }

    
    // MARK: - Actions
    
    @IBAction func handleDismiss(_ sender: Any) {
        // 화면전환 직전에, 내비게이션 바와 탭 바 생성
        self.navigationController?.navigationBar.isHidden = false
        tabBarController?.tabBar.isHidden = false
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func handleLogin(_ sender: Any) {
        self.navigationController?.navigationBar.isHidden = false
        let vc = FindingIDVC(nibName: "FindingIDVC", bundle: nil)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // 아이디 찾기 클릭 시,
    @IBAction func handleFindingID(_ sender: Any) {
        print("DEBUG: Clicked Finding ID")
    }
    
    // 비밀번호 찾기 클릭 시,
    @IBAction func handleFindingPW(_ sender: Any) {
        print("DEBUG: Clicked Finding Password")
    }
    
    // 회원가입 클릭 시,
    @IBAction func handleRegistration(_ sender: Any) {
        print("DEBUG: Clicked Registration")
    }
    
    
    // MARK: - Helper functions
    
    func configureUI() {
        let tfWidth = view.frame.width - 40
        // 아이디 Textfield
        idTextField.setDimensions(height: 50, width: tfWidth - 20)
        idTextField.placeholder = "   아이디"
        idTextField.keyboardType = .emailAddress
        idTextField.centerX(inView: view)
        idTextField.anchor(top: logoImage.bottomAnchor,
                           paddingTop: view.frame.height * 0.1)
        
        // 비밀번호 Textfield
        passwordTextField.setDimensions(height: 30, width: tfWidth - 20)
        custonTextField(tf: passwordTextField, width: tfWidth, leftImage: #imageLiteral(resourceName: "settings"), placehoder: "비밀번호")
        passwordTextField.isSecureTextEntry = true
        passwordTextField.keyboardType = .emailAddress
        passwordTextField.centerX(inView: view)
        passwordTextField.anchor(top: idTextField.bottomAnchor,
                           paddingTop: view.frame.height * 0.03)
        
        // 로그인 Button
        loginButton.backgroundColor = .mainOrange
        loginButton.layer.cornerRadius = 8
        loginButton.titleLabel?.font = UIFont.appBoldFontWith(size: 17)
        loginButton.centerX(inView: view)
        loginButton.anchor(top: passwordTextField.bottomAnchor,
                           paddingTop: view.frame.height * 0.05)
        loginButton.setDimensions(height: 40,
                                  width: view.frame.width * 0.75)
        
        // 아이디 찾기 Button
        findingIDButton.setDimensions(height: 18, width: 78)
        findingIDButton.anchor(top: loginButton.bottomAnchor,
                               left: idTextField.leftAnchor,
                               paddingTop: view.frame.height * 0.05)
        findingIDButton.titleLabel?.font = UIFont.appBoldFontWith(size: 14)
        
        // 비밀번호 찾기 Button
        findingPasswordButton.setDimensions(height: 18, width: 85)
        findingPasswordButton.centerX(inView: view)
        findingPasswordButton.anchor(top: findingIDButton.topAnchor)
        findingPasswordButton.titleLabel?.font = UIFont.appBoldFontWith(size: 14)
        
        // 좌측 구분선
        let leftXPoint = (view.center.x * 0.5) + 30
        view.addSubview(leftDividerView)
        leftDividerView.setDimensions(height: 18, width: 1)
        leftDividerView.anchor(top: findingPasswordButton.topAnchor,
                               left: view.leftAnchor,
                           paddingLeft: leftXPoint)
        
        
        // 우측 구분선
        let rightXPoint = (view.center.x * 0.5) + 30
        view.addSubview(rightDividerView)
        rightDividerView.setDimensions(height: 18, width: 1)
        rightDividerView.anchor(top: findingPasswordButton.topAnchor,
                           right: view.rightAnchor,
                           paddingRight: rightXPoint)
        
        
        // 회원가입 Button
        registrationButton.setDimensions(height: 18, width: 78)
        registrationButton.anchor(top: findingIDButton.topAnchor,
                                  right: idTextField.rightAnchor)
        registrationButton.titleLabel?.font = UIFont.appBoldFontWith(size: 14)
        
    }
    



}


private extension LoginVC {
    
    @objc
    func tapGesture() {
        view.endEditing(true)
    }
    
    func setupUI() {
        setupTapGesture()
    }
    
    func setupTapGesture() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapGesture))
        view.addGestureRecognizer(tapGestureRecognizer)
    }
}
