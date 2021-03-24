//
//  RegistrationUserInfoVC.swift
//  gongmanse
//
//  Created by 김우성 on 2021/03/22.
//

import UIKit




class RegistrationUserInfoVC: UIViewController {

    // MARK: - Properties
    
    var viewModel = RegistrationUserInfoViewModel()
    
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
    
    // Programmatic
    // 비밀번호 하단 조건 레이블
    private let bottomLabel: UILabel = {
        let label = UILabel()
        label.text = "8~16자, 영문 대소문자, 숫자, 특수문자를 사용해주세요."
        label.textColor = .red
        label.font = UIFont.appBoldFontWith(size: 10)
        label.textAlignment = .left
        return label
    }()
    
    @IBOutlet weak var nextButton: UIButton!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        cofigureNavi()
        configureNotificationObservers()
     
    }

    // MARK: - Actions
    
    @IBAction func handleNextPage(_ sender: Any) {
        let vc = CheckUserIdentificationVC()
        // "회원정보" 페이지에서 작성한 값들을 화면전환 전에 넘겨줌
        vc.userInfoData = self.userInfo
//        self.navigationController?.pushViewController(vc, animated: false)
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
        
        nextButton.backgroundColor = UIColor.progressBackgroundColor
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
        let tfWidth = view.frame.width - 125
        
        // 아이디 TextField
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
        
        
        // 비밀번호 하단 레이블
        view.addSubview(bottomLabel)
        bottomLabel.setDimensions(height: 10, width: tfWidth)
        bottomLabel.anchor(top: pwdTextField.bottomAnchor,
                           left: pwdTextField.leftAnchor,
                           paddingTop: 1,
                           paddingLeft: 5)
        
        
        
        
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
    
    // 내비게이션 타이틀 폰트 변경
    func cofigureNavi() {
        let title = UILabel()
        title.text = "회원가입"
        title.font = UIFont.appBoldFontWith(size: 17)
        navigationItem.titleView = title
    }
    
    func configureNotificationObservers() {
        // addTarget
        idTextField.addTarget        (self, action: #selector(textDidChange), for: .editingChanged)
        pwdTextField.addTarget       (self, action: #selector(textDidChange), for: .editingChanged)
        confirmPwdTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        nameTextField.addTarget      (self, action: #selector(textDidChange), for: .editingChanged)
        nicknameTextField.addTarget  (self, action: #selector(textDidChange), for: .editingChanged)
        emailTextField.addTarget     (self, action: #selector(textDidChange), for: .editingChanged)
    }
    
    // UITextField 타이핑 할때마다 값을 ViewModel로 전달
    @objc func textDidChange(sender: UITextField) {
        if sender == idTextField {
            viewModel.username = sender.text
            textFieldCheck(idTextField, text: sender.text!)  // 아이디 중복확인 API 사용
        } else if sender == pwdTextField {
            viewModel.password = sender.text
            textFieldCheck(pwdTextField, text: viewModel.password!)
        } else if sender == confirmPwdTextField {
            viewModel.confirm_password = sender.text
        } else if sender == nameTextField {
            viewModel.first_name = sender.text
        } else if sender == nicknameTextField {
            viewModel.nickname = sender.text
        } else {  // emailTextField
            viewModel.email = sender.text
        }
        updateForm() // 전달받은 값을 바탕으로 버튼의 색상 결정하는 메소드
    }
    
}


// MARK: - "다음" 버튼 배경색상 결정 로직

extension RegistrationUserInfoVC: FormViewModel {
    func updateForm() {
        nextButton.backgroundColor = viewModel.buttonBackgroundColor
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
    
    
    // configureObervation 으로 대체할 예정 03.24
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        let tf = textField as! SloyTextField
//
//        switch tf {
//        case idTextField:
//            let text = "\(idTextField.text!)" + "\(string)"
//            self.userInfo.username = text
//            textFieldCheck(idTextField, text: text)
//
//        case pwdTextField:
//            let text = "\(pwdTextField.text!)" + "\(string)"
//            self.userInfo.password = text
//            textFieldCheck(pwdTextField, text: text)
//
//        case confirmPwdTextField:
//            let text = "\(confirmPwdTextField.text!)" + "\(string)"
//            self.userInfo.confirm_password = confirmPwdTextField.text!
//            textFieldCheck(confirmPwdTextField, text: text)
//
//        case nameTextField:
//            let text = "\(nameTextField.text!)" + "\(string)"
//            self.userInfo.first_name = nameTextField.text!
//            textFieldCheck(nameTextField, text: text)
//
//        case nicknameTextField:
//            let text = "\(nicknameTextField.text!)" + "\(string)"
//            self.userInfo.nickname = nicknameTextField.text!
//            textFieldCheck(nicknameTextField, text: text)
//
//        case emailTextField:
//            let text = "\(emailTextField.text!)" + "\(string)"
//            self.userInfo.email = emailTextField.text!
//            textFieldCheck(emailTextField, text: text)
//
//        default:
//            print("DEBUG: didn't find textField in Registration...")
//        }
//        return true
//    }
}


// MARK: - UITextField Helper functions

private extension RegistrationUserInfoVC {
    // 키보드 유효성 검사를 위한 커스텀 메소드
    func textFieldCheck(_ tf: UITextField, text: String) {
        let textField = tf as! SloyTextField

        // textField 좌측에 나타날 이미지
        textField.rightViewMode = .always
        
        // TextField에 따른 로직
        switch textField {
        case idTextField:
            // TODO: 유효성검사
            // 중복검사 -> 완료
            CertificationDataManager().idDuplicateCheck(idDuplicateCheckInput(username: text), viewController: self)
            
        case pwdTextField:
            // TODO: pwd 유효성검사
            checkPassword(pwdTextField, text: text)
            
        case confirmPwdTextField:
            // TODO: pwd 와 일치여부
            CertificationDataManager().idDuplicateCheck(idDuplicateCheckInput(username: text), viewController: self)

        case nameTextField:
            // TODO: name 유효성검사
            CertificationDataManager().idDuplicateCheck(idDuplicateCheckInput(username: text), viewController: self)

        case nicknameTextField:
            // TODO: nickname 유효성검사 + 중복검사
            CertificationDataManager().idDuplicateCheck(idDuplicateCheckInput(username: text), viewController: self)

        case emailTextField:
            // TODO: email 유효성검사
            CertificationDataManager().idDuplicateCheck(idDuplicateCheckInput(username: text), viewController: self)

        default:
            print("DEBUG: default")
        }
    }
    
    func textFieldNullCheck(_ tf: UITextField) -> Bool {
        if tf.text == "" {
            print("DEBUG: 아무것도 입력안함.")
            return false
        } else { return true }
    }
    

    // 비밀번호 유효성검사
    func checkPassword(_ tf: SloyTextField, text: String) {
        if !textFieldNullCheck(tf) {
            tf.rightView = UIView()
        } else {
            if viewModel.passwordIsValid {
                // 8~16글자 + 대문자 한개 이상포함 + 소문자 + 숫자 조합 (한글X)
                // TextField RightView 이미지
                let rightView = settingLeftViewInTextField(tf, #imageLiteral(resourceName: "settings").withTintColor(.green))
                tf.rightView = rightView
                // TextField 하단 divider 색상 변경
            } else {
                // 위 조건 불충분한 경우
                // TextField RightView 이미지
                let rightView = settingLeftViewInTextField(tf, #imageLiteral(resourceName: "settings").withTintColor(.red))
                tf.rightView = rightView
                tf.border.backgroundColor = .red
            }

        }
    }
        
    // 비밀번호 확인 유효성검사
    func checkConfirmPassword() {
        
    }
    
    // 이름 유효성검사
    func checkname() {
        
    }
    
    // 닉네임 유효성검사
    func checkNickname() {
        
    }
    
    // 이메일 유효성검사
    func checkEmail() {
        
    }
    
}

// MARK: - API

extension RegistrationUserInfoVC {
    // 아이디 중복체크
    func idDuplicationCheckInVC(message: idDuplicateCheckResponse) {
        // 아이디 중복체크여부확인
        print("DEBUG: 아이디 중복체크여부결과 \(message.data)")
        if !textFieldNullCheck(idTextField) {
            idTextField.rightView = UIView()
        } else {
            if message.data == "0" {    // 중복아님
                let rightView = settingLeftViewInTextField(idTextField, #imageLiteral(resourceName: "settings").withTintColor(.green))
                idTextField.rightView = rightView
            } else {                    // 중복
                let rightView = settingLeftViewInTextField(idTextField, #imageLiteral(resourceName: "settings").withTintColor(.red))
                idTextField.rightView = rightView
            }
        }
        
    }
    
}
