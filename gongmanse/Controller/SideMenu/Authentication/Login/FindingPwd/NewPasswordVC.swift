//
//  NewPasswordVC.swift
//  gongmanse
//
//  Created by 김우성 on 2021/03/23.
//

import UIKit

class NewPasswordVC: UIViewController {

    // MARK: - Properties

    var viewModel = NewPasswordViewModel()
    
    // 새 비밀번호 / 새 비밀번호 재입력 텍스트필드
    private let newPasswordTextField = SloyTextField()
    private let reNewPasswordTextField = SloyTextField()
    
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
    
    // "완료" 버튼
    private let completeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("완료", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .progressBackgroundColor
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureNotificationObservers()
        configureBottomLabel()
    }
    
    
    // MARK: - Actions
    
    // 완료 버튼 클릭 시, 호출되는 콜백메소드
    @objc func handleComplete() {
        // 비밀번호 변경 API 호출; 성공적으로 변경되었다면, "CompleteChangePwdVC" 로 화면전환
        NewPasswordDataManager().changePassword(NewPasswordInput(username: "\(viewModel.username)", password: "\(viewModel.password)"), viewController: self)
    }
    
    
    // 텍스트필드 콜벡메소드
    @objc func textDidChange(sender: UITextField) {
        guard let text = sender.text else { return }
        
        switch sender {
        case newPasswordTextField:
            viewModel.password = text
            textFieldCheck(newPasswordTextField, text: text)
            
        case reNewPasswordTextField:
            viewModel.rePassword = text
            textFieldCheck(reNewPasswordTextField, text: text)
        default:
            print("DEBUG: default in switch Statement...")
        }
        
        // "새 비밀번호"와 "새 비밀번호 재입력" 이 일치한다면 완료 버튼 색상 변경 로직 추가
        completeButton.backgroundColor = viewModel.formIsValid ? .mainOrange : .progressBackgroundColor
    }
    
    // 텍스트필드에 콜벡메소드 추가
    func configureNotificationObservers() {
        newPasswordTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        reNewPasswordTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
    }
    
    
    // MARK: - Helpers
    
    func configureUI() {
        // 크기 비율
        let tfWidth = Constant.width * 0.73
        let tfHeight = Constant.height * 0.06
        
        // leftView - 추후에 각각의 텍스트 필드에 맞는 이미지로 변경할 것.
        let passwordleftView = addLeftView(image: #imageLiteral(resourceName: "myActivity"))
        let rePasswordleftView = addLeftView(image: #imageLiteral(resourceName: "myActivity"))
    
        // 오토레이아웃 적용
        view.addSubview(newPasswordTextField)
        setupTextField(newPasswordTextField, placehoder: "새 비밀번호", leftView: passwordleftView)
        newPasswordTextField.isSecureTextEntry = true
        newPasswordTextField.setDimensions(height: tfHeight, width: tfWidth)
        newPasswordTextField.centerX(inView: view)
        newPasswordTextField.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                                    paddingTop: view.frame.height * 0.1)
        
        view.addSubview(reNewPasswordTextField)
        setupTextField(reNewPasswordTextField, placehoder: "새 비밀번호 재입력", leftView: rePasswordleftView)
        reNewPasswordTextField.isSecureTextEntry = true
        reNewPasswordTextField.setDimensions(height: tfHeight, width: tfWidth)
        reNewPasswordTextField.centerX(inView: view)
        reNewPasswordTextField.anchor(top: newPasswordTextField.bottomAnchor,
                           paddingTop: 20)
        
        // "완료" UIButton
        view.addSubview(completeButton)
        completeButton.setDimensions(height: 40, width: 260)
        completeButton.layer.cornerRadius = 10
        completeButton.centerX(inView: view)
        completeButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor,
                              paddingBottom: 30)
        completeButton.addTarget(self, action: #selector(handleComplete), for: .touchUpInside)
        }
    
        
    // MARK: 텍스트필드 하단 레이블 UI
    func configureBottomLabel() {
        let tfWidth = view.frame.width - 125

        // 비밀번호 하단 레이블
        view.addSubview(passwordBottomLabel)
        passwordBottomLabel.setDimensions(height: 10, width: tfWidth)
        passwordBottomLabel.anchor(top: newPasswordTextField.bottomAnchor,
                           left: newPasswordTextField.leftAnchor,
                           paddingTop: 3,
                           paddingLeft: 5)
        // 비밀번호 재입력 하단 레이블
        view.addSubview(confirmPasswrodBottomLabel)
        confirmPasswrodBottomLabel.setDimensions(height: 10, width: tfWidth)
        confirmPasswrodBottomLabel.anchor(top: reNewPasswordTextField.bottomAnchor,
                                          left: reNewPasswordTextField.leftAnchor,
                                          paddingTop: 3,
                                          paddingLeft: 5)
    }
}


// MARK: - API

extension NewPasswordVC {
    // 비밀번호 변경 API 호출
    func didSucceed(response: NewPasswordResponse) {
        // 비밀번호 변경 성공
        self.navigationController?.pushViewController(CompleteChangePwdVC(), animated: true)
    }
}


// MARK: - UITextField Helpers

extension NewPasswordVC {
    
    func textFieldCheck(_ tf: UITextField, text: String) { // 키보드 유효성 검사를 위한 커스텀 메소드
        let textField = tf as! SloyTextField
        textField.rightViewMode = .always                  // textField 좌측에 나타날 이미지
        
        switch textField {                                 // textField에 따라 api를 통한 유효성검사가 있는 경우를 위해 구분
        case newPasswordTextField:
            // 유효성 검사 : 정규표현식(영문 대소문자 + 숫자 + 특수문자 조합여부) + 글자수 제한로직
            checkValidationAndLabelUpdate(newPasswordTextField, label: passwordBottomLabel, condition: viewModel.passwordIsValid)

        case reNewPasswordTextField:
            // 유효성 검사 : 새 비밀번호와 일치여부
            checkValidationAndLabelUpdate(reNewPasswordTextField, label: confirmPasswrodBottomLabel, condition: viewModel.confirmPasswrdIsVaild)
        default:
            print("DEBUG: \(#function) didn't have any responder...")
        }
    }
    
    func textFieldNullCheck(_ tf: UITextField) -> Bool { // Null Check 커스텀메소드
        if tf.text == "" {
            return false
        } else { return true }
    }
    
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
}

// MARK: - TapGesture

private extension NewPasswordVC {
    
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
