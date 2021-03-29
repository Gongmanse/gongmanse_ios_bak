//
//  RegistrationUserInfoVC.swift
//  gongmanse
//
//  Created by 김우성 on 2021/03/22.
//

import UIKit

class RegistrationUserInfoVC: UIViewController {

    // MARK: - Properties
    
    var viewModel = RegistrationUserInfoViewModel()         // viewModel 생성
    
    // MARK: IBOutlet
    // 오토레이아웃 - CODE
    @IBOutlet weak var currentProgressView: UIView!
    @IBOutlet weak var totalProgressView: UIView!
    @IBOutlet weak var pageID: UILabel!
    @IBOutlet weak var pageNumber: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    
    // textField
    @IBOutlet weak var idTextField: SloyTextField!
    @IBOutlet weak var pwdTextField: SloyTextField!
    @IBOutlet weak var confirmPwdTextField: SloyTextField!
    @IBOutlet weak var nameTextField: SloyTextField!
    @IBOutlet weak var nicknameTextField: SloyTextField!
    @IBOutlet weak var emailTextField: SloyTextField!
    
    // 프로퍼티 생성 및 오토레이아웃 - CODE
    // 아이디(username) 하단 조건 레이블
    private let idBottomLabel: UILabel = {
        let label = UILabel()
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
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()                       // 전반적인 UI
        configureBottomLabel()              // textField 하단에 생성되는 Label UI
        cofigureNavi()                      // navigation 관련 UI
        configureNotificationObservers()    // textField observing 로직
    }

    
    // MARK: - Actions
    
    // 클릭 시, 다음 페이지 이동 로직
    @IBAction func handleNextPage(_ sender: Any) {
        let vc = CheckUserIdentificationVC()                                // 화면전환을 희망하는 컨트롤러 프로퍼티 생성
        vc.viewModel = self.viewModel
        
        if viewModel.formIsValid {
            self.navigationController?.pushViewController(vc, animated: false)  // push를 통한 화면전환
        }
    }
    
    
    // MARK: - Helper functions

    func configureUI() {
        tabBarController?.tabBar.isHidden = true
        
        nextButton.backgroundColor = UIColor.progressBackgroundColor        // 제플린 설정된 색상값 적용
        nextButton.layer.cornerRadius = 10                                  // 제플린 설정된 value
        
        // ProgressView 오토레이아웃(화면 최상단에 있는 회색 View)
        totalProgressView.centerX(inView: view)
        totalProgressView.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                                 left: view.leftAnchor,
                                 right: view.rightAnchor,
                                 height: 4)
        totalProgressView.backgroundColor = UIColor(white: 200.0 / 255.0, alpha: 1.0)
        
        // 현재 페이지의 진행상황을 나타내는 View(화면 최상단에 있는 .mainOrange View)
        currentProgressView.setDimensions(height: 4, width: view.frame.width * 0.5) // 진행상황에 맞게 width값 변경
        currentProgressView.anchor(top:totalProgressView.topAnchor,
                                   left: totalProgressView.leftAnchor)
        currentProgressView.backgroundColor = .mainOrange
        
        // 현재 페이지 명칭을 나타내는 UILabel("정보기입" 라고 작성된 레이블)(화면 좌상단)
        pageID.setDimensions(height: view.frame.height * 0.02,
                             width: view.frame.width * 0.15)
        pageID.anchor(top: totalProgressView.bottomAnchor,
                      left: totalProgressView.leftAnchor,
                      paddingTop: 11,
                      paddingLeft: 20)
        pageID.font = UIFont.appBoldFontWith(size: 14)
        pageID.textAlignment = .left
        
        // 현재 페이지 명칭을 나타내는 UILabel("2/4" 라고 작성된 레이블)(화면 우상단)
        pageNumber.setDimensions(height: view.frame.height * 0.02,
                                 width: view.frame.width * 0.15)
        pageNumber.anchor(top: totalProgressView.bottomAnchor,
                          right: view.rightAnchor,
                          paddingTop: 11,
                          paddingRight: 20)
        pageNumber.font = UIFont.appBoldFontWith(size: 14)
        pageNumber.textAlignment = .right
            
        // MARK: 텍스트필드
        let tfWidth = view.frame.width - 125                                        // textField width 값 기준
    
        // 아이디 TextField
        let idTfLeftView = settingLeftViewInTextField(idTextField, #imageLiteral(resourceName: "myActivity"))              // leftView 생성 커스텀메소드 활용
        setupTextField(idTextField, placehoder: "아이디", leftView: idTfLeftView)
        idTextField.setDimensions(height: 50, width: tfWidth)                       // 높이 크기 조절 커스텀메소드 활용
        idTextField.centerX(inView: view)                                           // 오토레이아웃 적용
        idTextField.anchor(top: totalProgressView.bottomAnchor,                     // 오토레이아웃 적용
                           paddingTop: view.frame.height * 0.05)                    // 이하 textField 코드 주석 생략
        
        // 비밀번호 TextField
        let pwdTfLeftView = settingLeftViewInTextField(idTextField, #imageLiteral(resourceName: "myActivity"))
        setupTextField(pwdTextField, placehoder: "비밀번호", leftView: pwdTfLeftView)
        pwdTextField.setDimensions(height: 50, width: tfWidth)
        pwdTextField.isSecureTextEntry = true
        pwdTextField.centerX(inView: view)
        pwdTextField.anchor(top: idTextField.bottomAnchor,
                           paddingTop: view.frame.height * 0.03)
        
        // 비밀번호 재입력 TextField
        let confirmPwdTfLeftView = settingLeftViewInTextField(idTextField, #imageLiteral(resourceName: "myActivity"))
        setupTextField(confirmPwdTextField, placehoder: "비밀번호 재입력", leftView: confirmPwdTfLeftView)
        confirmPwdTextField.setDimensions(height: 50, width: tfWidth)
        confirmPwdTextField.isSecureTextEntry = true                                  // 텍스트필드 작성된 값 보안설정
        confirmPwdTextField.centerX(inView: view)
        confirmPwdTextField.anchor(top: pwdTextField.bottomAnchor,
                           paddingTop: view.frame.height * 0.03)
        
        // 이름 TextField
        let nameTfLeftView = settingLeftViewInTextField(idTextField, #imageLiteral(resourceName: "myActivity"))
        setupTextField(nameTextField, placehoder: "이름", leftView: nameTfLeftView)
        nameTextField.setDimensions(height: 50, width: tfWidth)
        nameTextField.centerX(inView: view)
        nameTextField.anchor(top: confirmPwdTextField.bottomAnchor,
                           paddingTop: view.frame.height * 0.03)
        
        // 닉네임 TextField
        let nicknameLeftView = settingLeftViewInTextField(idTextField, #imageLiteral(resourceName: "myActivity"))
        setupTextField(nicknameTextField, placehoder: "닉네임", leftView: nicknameLeftView)
        nicknameTextField.setDimensions(height: 50, width: tfWidth)
        nicknameTextField.centerX(inView: view)
        nicknameTextField.anchor(top: nameTextField.bottomAnchor,
                           paddingTop: view.frame.height * 0.03)

        // 이메일 TextField
        let emailLeftView = settingLeftViewInTextField(idTextField, #imageLiteral(resourceName: "myActivity"))
        setupTextField(emailTextField, placehoder: "이메일", leftView: emailLeftView)
        emailTextField.setDimensions(height: 50, width: tfWidth)
        emailTextField.centerX(inView: view)
        emailTextField.anchor(top: nicknameTextField.bottomAnchor,
                           paddingTop: view.frame.height * 0.03)
    }
    
    // textField 공통 세팅 커스텀메소드
//    private func setupTextField(_ tf: UITextField, placehoder: String, leftView: UIView) {
//        tf.placeholder = placehoder
//        tf.leftViewMode = .always
//        tf.tintColor = .gray
//        tf.leftView = leftView
//        tf.keyboardType = .emailAddress
//    }
    
    // MARK: 텍스트필드 하단 레이블 UI
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
    
    
    // MARK: 내비게이션 UI 설정
    func cofigureNavi() {
        // navigation.title의 텍스트값 추가가 아닌 view 자체를 추가함.
        let title = UILabel()
        title.text = "회원가입"
        title.font = UIFont.appBoldFontWith(size: 17)
        navigationItem.titleView = title
    }
    
    // MARK: 텍스트필드 콜벡메소드 추가
    func configureNotificationObservers() {
    
        idTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        pwdTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        confirmPwdTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        nameTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        nicknameTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        emailTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
    }
    
    // 텍스트필드 콜백메소드
    @objc func textDidChange(sender: UITextField) {
        sender.tintColor = .mainOrange                                                  // 커서 색상변경
        sender.leftView?.tintColor = viewModel.leftViewColor                            // TextField가 firstResponder여부에 따라서 leftView의 색상을 변경

        if sender == idTextField {
            viewModel.username = sender.text                                            // 뷰모델에 value 할당
            textFieldCheck(idTextField, text: sender.text!)                             // 아이디 중복확인 API 사용
        } else if sender == pwdTextField {                                              // 이하 생략
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
        } else {
            viewModel.email = sender.text
            textFieldCheck(emailTextField, text: viewModel.email!)
        }
        updateForm() // 전달받은 값을 바탕으로 버튼의 색상 결정하는 메소드
    }
    
}


// MARK: - "다음" 버튼 배경색상 결정 로직

extension RegistrationUserInfoVC: FormViewModel {                       // 버튼 색상 변경 로직
    func updateForm() {
        nextButton.backgroundColor = viewModel.buttonBackgroundColor    // viewModel value에 따른 색상결정
    }
}


// MARK: - UITextField Helpers

private extension RegistrationUserInfoVC {
    
    func textFieldCheck(_ tf: UITextField, text: String) { // 키보드 유효성 검사를 위한 커스텀 메소드
        let textField = tf as! SloyTextField
        textField.rightViewMode = .always                  // textField 좌측에 나타날 이미지
        
        switch textField {                                 // textField에 따라 api를 통한 유효성검사가 있는 경우를 위해 구분
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
    
    func textFieldNullCheck(_ tf: UITextField) -> Bool { // Null Check 커스텀메소드
        if tf.text == "" {
            return false
        } else { return true }
    }
}


// MARK: - Validation Functions

extension RegistrationUserInfoVC {
    // 유효성검사가 1 개인 경우 사용하는 커스텀메소드
    func checkValidationAndLabelUpdate(_ tf: SloyTextField, label: UILabel, condition: Bool) {
        /* 텍스트필드에 입력된 글자가 없는 경우 */
        if !textFieldNullCheck(tf) {            // 관련주석 바로 "checkTwoValidationAndLabelUpdate" 참조
            UIView.animate(withDuration: 0.3) {
                tf.rightView = UIView()
                label.alpha = 0
                tf.isVailedIndex = true
            }
        } else {
            /* viewModel 로직에 충족된 경우 */
            if condition {
                UIView.animate(withDuration: 0.3) {
                    let rightView = self.settingLeftViewInTextField(tf, #imageLiteral(resourceName: "settings").withTintColor(.green))
                    tf.rightView = rightView
                    label.alpha = 0
                    tf.isVailedIndex = true
                }
            /* viewModel 로직에 불충족된 경우 */
            } else {
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
    
    // 유효성검사가 2 개인 경우 사용하는 커스텀메소드
    func checkTwoValidationAndLabelUpdate(_ tf: SloyTextField, label: UILabel, first: String, second: String, condition: Bool) {
        /* 텍스트필드에 입력된 글자가 없는 경우 */
        if !textFieldNullCheck(tf) {
            UIView.animate(withDuration: 0.3) {
                tf.rightView = UIView()                           // 빈 View생성
                label.alpha = 0                                   // 상단 label 알파 value
                tf.isVailedIndex = true                           // 텍스트필드 내부 프로퍼티값 조정
            }                                                     // true로 지정 -> .gray OR .mainOrange 중 색상결정
        } else {
            /* 글자 수가 2자 이상인 경우 (아이디) 글자 수가 2자 이상 12자 미만인경우(닉네임) */
            if (tf != nicknameTextField) ? (tf.text!.count < 2) : (tf.text!.count < 2 || tf.text!.count > 12) {
                UIView.animate(withDuration: 0.3) { // 2글자보다 많은 경우 +a
                    // TextField RightView 이미지
                    let rightView = self.settingLeftViewInTextField(tf, #imageLiteral(resourceName: "settings").withTintColor(.red))// rightView 생성
                    tf.rightView = rightView                                                  // 텍스트필드의 rightView에 생성한 view 할당
                    label.text = first                                                        // 텍스트 기입
                    tf.border.backgroundColor = .red                                          // 하단 borderView 색상
                    tf.isVailedIndex = false // 텍스트필드 내부 프로퍼티 값 변경(유효성검사를 위한 인덱스) false면 .red
                    label.alpha = 1                                                // 상단에 나타나는 라벨 알파 value
                }
                /* 글자가 3글자 이상 있는경우 + 조건을 만족한 경우 */
            } else {
                UIView.animate(withDuration: 0.3) {
                    let rightView = self.settingLeftViewInTextField(tf, #imageLiteral(resourceName: "settings").withTintColor(condition ? .green : .red))
                    tf.rightView = rightView
                    label.text = condition ? "" : second                      // condition = viewModel에서 로직수행 후 bool값
                    tf.border.backgroundColor = condition ? .mainOrange : .red// condition에 따른 하단 구분선 색상결정
                    label.alpha = condition ? 0 : 1                           // condition에 따른 알파 value
                    tf.isVailedIndex = condition ? true : false // condition에 따른 유효성검사 인덱스 value

                    /* 다음버튼 활성화를 위한 index value Changed */
                    if condition {
                        // viewModel에서 로직처리를 위해 value 할당
                        // idTextField와 nickname, 나머지는 뷰모델에서 처리중.
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
    /* API를 활용한 아이디 중복체크 */
    func idDuplicationCheckInVC(message: idDuplicateCheckResponse) { // API를 통해 전달
        var result: Bool
        if message.data == "0" {
            result = true
        } else {
            result = false
        }
        checkTwoValidationAndLabelUpdate(idTextField, label: idBottomLabel, first: "2자 이상의 연문과 숫자를 사용하세요.", second: "중복된 아이디입니다.", condition: result)
    }
    
    /* API를 활용한 닉네임 중복체크 */
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
