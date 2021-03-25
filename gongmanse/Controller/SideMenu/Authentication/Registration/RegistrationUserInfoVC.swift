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
    
    // Programmatic) 하단 레이블
    // 아이디(username) 하단 조건 레이블
    private let idBottomLabel: UILabel = {
        let label = UILabel()
        label.text = "" //"2자 이상의 영문과 숫자를 사용하세요."
        label.textColor = .red
        label.font = UIFont.appBoldFontWith(size: 10)
        label.textAlignment = .left
        label.alpha = 0
        return label
    }()
    
    // 비밀번호 하단 조건 레이블
    private let passwordBottomLabel: UILabel = {
        let label = UILabel()
        label.text = "8~16자, 영문 대소문자, 숫자, 특수문자를 사용해주세요."
        label.textColor = .red
        label.font = UIFont.appBoldFontWith(size: 10)
        label.textAlignment = .left
        label.alpha = 0
        return label
    }()
    
    // 비밀번호 재입력 하단 조건 레이블
    private let confirmPasswrodBottomLabel: UILabel = {
        let label = UILabel()
        label.text = "비밀번호가 일치하지 않습니다."
        label.textColor = .red
        label.font = UIFont.appBoldFontWith(size: 10)
        label.textAlignment = .left
        label.alpha = 0
        return label
    }()
    
    // 이름 하단 조건 레이블
    private let nameBottomLabel: UILabel = {
        let label = UILabel()
        label.textColor = .red
        label.text = "한글을 입력해주세요."
        label.font = UIFont.appBoldFontWith(size: 10)
        label.textAlignment = .left
        label.alpha = 0
        return label
    }()
    
    // 닉네임 하단 조건 레이블
    private let nicknameBottomLabel: UILabel = {
        let label = UILabel()
        label.textColor = .red
        label.font = UIFont.appBoldFontWith(size: 10)
        label.textAlignment = .left
        label.alpha = 0
        return label
    }()
    
    // 이메일 하단 조건 레이블
    private let emailBottomLabel: UILabel = {
        let label = UILabel()
        label.textColor = .red
        label.text = "이메일 형식에 맞게 입력해주세요."
        label.font = UIFont.appBoldFontWith(size: 10)
        label.textAlignment = .left
        label.alpha = 0
        return label
    }()
    
    @IBOutlet weak var nextButton: UIButton!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureBottomLabel()
        cofigureNavi()
        configureNotificationObservers()
    }

    // MARK: - Actions
    
    @IBAction func handleNextPage(_ sender: Any) {
        let vc = CheckUserIdentificationVC()
        self.navigationController?.pushViewController(vc, animated: false)
    }
    
    
    // MARK: - Helper functions

    func configureUI() {
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
    
    // 하단 레이블 오토레이아웃
    func configureBottomLabel() {
        let tfWidth = view.frame.width - 125

        // 아이디 하단 레이블
        view.addSubview(idBottomLabel)
        idBottomLabel.setDimensions(height: 10, width: tfWidth)
        idBottomLabel.anchor(top: idTextField.bottomAnchor,
                           left: idTextField.leftAnchor,
                           paddingTop: 3,
                           paddingLeft: 5)
        // 비밀번호 하단 레이블
        view.addSubview(passwordBottomLabel)
        passwordBottomLabel.setDimensions(height: 10, width: tfWidth)
        passwordBottomLabel.anchor(top: pwdTextField.bottomAnchor,
                           left: pwdTextField.leftAnchor,
                           paddingTop: 3,
                           paddingLeft: 5)
        // 비밀번호 재입력 하단 레이블
        view.addSubview(confirmPasswrodBottomLabel)
        confirmPasswrodBottomLabel.setDimensions(height: 10, width: tfWidth)
        confirmPasswrodBottomLabel.anchor(top: confirmPwdTextField.bottomAnchor,
                                          left: confirmPwdTextField.leftAnchor,
                                          paddingTop: 3,
                                          paddingLeft: 5)
        // 이름 하단 레이블
        view.addSubview(nameBottomLabel)
        nameBottomLabel.setDimensions(height: 10, width: tfWidth)
        nameBottomLabel.anchor(top: nameTextField.bottomAnchor,
                                          left: nameTextField.leftAnchor,
                                          paddingTop: 3,
                                          paddingLeft: 5)
        // 닉네임 하단 레이블
        view.addSubview(nicknameBottomLabel)
        nicknameBottomLabel.setDimensions(height: 10, width: tfWidth)
        nicknameBottomLabel.anchor(top: nicknameTextField.bottomAnchor,
                                          left: nicknameTextField.leftAnchor,
                                          paddingTop: 3,
                                          paddingLeft: 5)
        // 이메일 하단 레이블
        view.addSubview(emailBottomLabel)
        emailBottomLabel.setDimensions(height: 10, width: tfWidth)
        emailBottomLabel.anchor(top: emailTextField.bottomAnchor,
                                          left: emailTextField.leftAnchor,
                                          paddingTop: 3,
                                          paddingLeft: 5)
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
        // 커서 색상
        sender.tintColor = .mainOrange
        
        // TextField가 firstResponder여부에 따라서 leftView의 색상을 변경
        sender.leftView?.tintColor = viewModel.leftViewColor

        if sender == idTextField {
            viewModel.username = sender.text
            textFieldCheck(idTextField, text: sender.text!)  // 아이디 중복확인 API 사용
            // TextField의 상태에 따라서 leftView tintColor 설정
        } else if sender == pwdTextField {
            viewModel.password = sender.text
            textFieldCheck(pwdTextField, text: viewModel.password!)
            
        } else if sender == confirmPwdTextField {
            viewModel.confirm_password = sender.text
            textFieldCheck(confirmPwdTextField, text: viewModel.confirm_password!)
            
        } else if sender == nameTextField {
            viewModel.first_name = sender.text
            textFieldCheck(nameTextField, text: viewModel.first_name!)

        } else if sender == nicknameTextField {
            viewModel.nickname = sender.text
            textFieldCheck(nicknameTextField, text: viewModel.nickname!)
            
        } else {  // emailTextField
            viewModel.email = sender.text
            textFieldCheck(emailTextField, text: viewModel.email!)
            
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
            // 유효성검사 : 중복여부확인 API + 글자수 제한로직
            CertificationDataManager().idDuplicateCheck(idDuplicateCheckInput(username: text), viewController: self)
            
        case pwdTextField:
            // 유효성 검사 : 정규표현식(영문 대소문자 + 숫자 + 특수문자 조합여부) + 글자수 제한로직
            checkValidationAndLabelUpdate(pwdTextField, label: passwordBottomLabel, condition: viewModel.passwordIsValid)
            
        case confirmPwdTextField:
            // 유효성 검사 : viewModel
            checkValidationAndLabelUpdate(confirmPwdTextField, label: confirmPasswrodBottomLabel, condition: viewModel.confirmPasswrdIsVaild)
            
        case nameTextField:
            // 유효성 검사 : 정규표현식(한글)
            checkValidationAndLabelUpdate(nameTextField, label: nameBottomLabel, condition: viewModel.nameIslVaild)

        case nicknameTextField:
            // 유효성 검사 : 중복여부확인 API + 글자수 제한로직
            CertificationDataManager().nicknameDuplicateCheck(nicknameDulicateCheckInput(nickname: text), viewController: self)
            
        case emailTextField:
            // 유효성 검사 : 정규표현식(이메일양식)
            checkValidationAndLabelUpdate(emailTextField, label: emailBottomLabel, condition: viewModel.emailIsValid)

        default:
            print("DEBUG: \(#function) didn't have any responder...")
        }
    }
    
    func textFieldNullCheck(_ tf: UITextField) -> Bool {
        if tf.text == "" {
            return false
        } else { return true }
    }

}


// MARK: - Validation Functions

extension RegistrationUserInfoVC {
    // 유효성검사 + 하단 텍스트필드 입력 조건 레이블 세팅 커스텀메소드
    func checkValidationAndLabelUpdate(_ tf: SloyTextField, label: UILabel, condition: Bool) {
        // tf Null 체크
        if !textFieldNullCheck(tf) { // 아무것도 입력하지 않은 경우
            UIView.animate(withDuration: 0.3) {
                tf.rightView = UIView()
                label.alpha = 0
                tf.isVailedIndex = true
            }
            
        } else {
            if condition {           // 조건을 모두 만족한 경우
                UIView.animate(withDuration: 0.3) {
                    // TextField RightView 이미지
                    let rightView = self.settingLeftViewInTextField(tf, #imageLiteral(resourceName: "settings").withTintColor(.green))
                    tf.rightView = rightView
                    label.alpha = 0
                    tf.isVailedIndex = true
                }
                
            } else {                 // 조건을 만족하지 못한 경우
                UIView.animate(withDuration: 0.3) {
                    // TextField RightView 이미지
                    let rightView = self.settingLeftViewInTextField(tf, #imageLiteral(resourceName: "settings").withTintColor(.red))
                    tf.rightView = rightView
                    tf.border.backgroundColor = .red
                    label.alpha = 1
                    tf.isVailedIndex = false
                }
                
            }
            
        }
    }
    
    // 유효성검사 + 하단 텍스트필드 입력 조건 레이블 세팅 커스텀메소드
    func checkTwoValidationAndLabelUpdate(_ tf: SloyTextField, label: UILabel, first: String, second: String, condition: Bool) {
        // tf Null 체크
        if !textFieldNullCheck(tf) {                // 아무것도 입력하지 않은 경우
            UIView.animate(withDuration: 0.3) {
                tf.rightView = UIView()
                label.alpha = 0
                tf.isVailedIndex = true
            }
        } else { // 텍스트가 있는 경우
            // nicknameTextField의 경우 12자 글자 제한적용.
            if (tf != nicknameTextField) ? (tf.text!.count < 2) : (tf.text!.count < 2 || tf.text!.count > 12) {
                UIView.animate(withDuration: 0.3) { // 2글자보다 많은 경우 +a
                    // TextField RightView 이미지
                    let rightView = self.settingLeftViewInTextField(tf, #imageLiteral(resourceName: "settings").withTintColor(.red))
                    tf.rightView = rightView
                    label.text = first
                    tf.border.backgroundColor = .red
                    tf.isVailedIndex = false
                    label.alpha = 1
                }
            } else {                                // 글자가 3글자 이상 있는경우 + 조건을 만족한 경우
                UIView.animate(withDuration: 0.3) { //
                    let rightView = self.settingLeftViewInTextField(tf, #imageLiteral(resourceName: "settings").withTintColor(condition ? .green : .red))
                    tf.rightView = rightView
                    label.text = condition ? "" : second
                    tf.border.backgroundColor = condition ? .mainOrange : .red
                    label.alpha = condition ? 0 : 1
                    tf.isVailedIndex = condition ? true : false

                    // 다음버튼 활성화를 위한 index value Changed
                    if condition {
                        if tf == self.idTextField { self.viewModel.idIsValid =  true }
                        else { self.viewModel.nicknameIsValid = true }
                    }
                    
                }
                
            }
        }
    }
}


// MARK: - API

extension RegistrationUserInfoVC {
    /* 아이디 중복체크 */
    func idDuplicationCheckInVC(message: idDuplicateCheckResponse) {
        var result: Bool
        if message.data == "0" {
            result = true
        } else {
            result = false
        }
        checkTwoValidationAndLabelUpdate(idTextField, label: idBottomLabel, first: "2자 이상의 연문과 숫자를 사용하세요.", second: "중복된 아이디입니다.", condition: result)
    }
    
    /* 닉네임 중복체크 */
    func nicknameDuplicationCheckInVC(message: nicknameDuplicateCheckResponse) {
        var result: Bool
        if message.data == "0" {
            result = true
        } else {
            result = false
        }
        checkTwoValidationAndLabelUpdate(nicknameTextField, label: nicknameBottomLabel, first: "2~12자를 사용하세요.", second: "중복된 닉네임입니다.", condition: result)
    }
    
}
