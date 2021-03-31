//
//  LoginVC.swift
//  gongmanse
//
//  Created by 김우성 on 2021/03/19.
//

import UIKit

class LoginVC: UIViewController {
    
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
        setupUI()           // Custom TextField UI 설정
        cofigureNotificationObservers()
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
        LoginDataManager().sendingLoginInfo(LoginInput(usr: "woosung", pwd: "12341234"), viewController: self)
    }
    
    // 아이디 찾기 클릭 시,
    @IBAction func handleFindingID(_ sender: Any) {
        self.navigationController?.navigationBar.isHidden = false
        let vc = FindingIDVC(nibName: "FindingIDVC", bundle: nil)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // 비밀번호 찾기 클릭 시,
    @IBAction func handleFindingPW(_ sender: Any) {
        self.navigationController?.navigationBar.isHidden = false
        let vc = FindingPwdVC(nibName: "FindingPwdVC", bundle: nil)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // 회원가입 클릭 시,
    @IBAction func handleRegistration(_ sender: Any) {
        print("DEBUG: Clicked Registration")
    }
    
    
    // MARK: - Helper functions
    
    func configureUI() {
        /* UITextField Properties and LeftView */
        let tfWidth = view.frame.width - 40
        
        // 아이디 TextField leftView
        let idImage = #imageLiteral(resourceName: "myActivity")
        let idleftView = UIView(frame: CGRect(x: 0, y: 10, width: 20, height: 20))
        let idimageView = UIImageView(frame: CGRect(x: 0, y: 10, width: 20, height: 20))
        idimageView.image = idImage
        idleftView.addSubview(idimageView)
        
        // 비밀번호 TextField leftView
        let passwordImage = #imageLiteral(resourceName: "myActivity")
        let passwordleftView = UIView(frame: CGRect(x: 0, y: 10, width: 20, height: 20))
        let passwordimageView = UIImageView(frame: CGRect(x: 0, y: 10, width: 20, height: 20))
        passwordimageView.image = passwordImage
        passwordleftView.addSubview(passwordimageView)
        
        /* UITextField setting */
        // 아이디 Textfield
        idTextField.setDimensions(height: 50, width: tfWidth - 20)
        setupTextField(idTextField, placehoder: "아이디", leftView: idleftView)
        idTextField.centerX(inView: view)
        idTextField.anchor(top: logoImage.bottomAnchor,
                           paddingTop: view.frame.height * 0.1)
        
        // 비밀번호 Textfield
        passwordTextField.setDimensions(height: 50, width: tfWidth - 20)
        setupTextField(passwordTextField, placehoder: "비밀번호", leftView: passwordleftView)
        passwordTextField.isSecureTextEntry = true
        
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
    

    @objc func textDidChange(sender: UITextField) {
        sender.tintColor = .mainOrange
        sender.leftView?.tintColor = .mainOrange
    }
    
    
    // 텍스트 필드 콜백메소드 추가
    func cofigureNotificationObservers() {
        idTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
    }
    
//    // textField 공통 세팅 커스텀메소드
//    private func setupTextField(_ tf: UITextField, placehoder: String, leftView: UIView) {
//        tf.placeholder = placehoder
//        tf.leftViewMode = .always
//        tf.tintColor = .gray
//        tf.leftView = leftView
//        tf.keyboardType = .emailAddress
//    }
}


// MARK: - CustomTextField

private extension LoginVC {
    
    @objc func tapGesture() {
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

// MARK: - API

extension LoginVC {
    func didSucceedLogin(_ token: String?) {  // 로그인 성공한 경우
        // 토큰 전달
        guard let token = token else { return }
        Constant.token = token
        
        // 회면전환 - Main Controller 로 이동.
        self.navigationController?.navigationBar.isHidden = false
        self.tabBarController?.tabBar.isHidden = false
        self.navigationController?.popViewController(animated: true)
    }
    
    func didFaildLogin(_ response: LoginResponse) {
        print("DEBUG: 실패이유 = \(response.message!)")
    }
}
