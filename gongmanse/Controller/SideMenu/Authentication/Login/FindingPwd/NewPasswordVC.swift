//
//  NewPasswordVC.swift
//  gongmanse
//
//  Created by 김우성 on 2021/03/23.
//

import UIKit

class NewPasswordVC: UIViewController {

    // MARK: - Properties
    
//    var viewModel = FindingIDByPhoneViewModel()
    
    var pageIndex: Int! // 상단탭바 구현을 위한 프로퍼티
    
    
    private let newPasswordTextField = SloyTextField()
    private let reNewPasswordTextField = SloyTextField()
    
    
    
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
    }
    
    
    // MARK: - Actions
    
    // 완료 버튼 클릭 시, 호출되는 콜백메소드
    @objc func handleComplete() {
//        if viewModel.formIsValid { // 인증번호가 사용자가 타이핑한 숫자와 일치하는 경우
//            // Transition Controller
//            let vc = NewPasswordVC()
////            vc.viewModel = self.viewModel
//            self.navigationController?.pushViewController(vc, animated: true)
//        }
        
        self.navigationController?.pushViewController(NewPasswordVC(), animated: true)
    }
    
    
    // 텍스트필드 콜벡메소드
    @objc func textDidChange(sender: UITextField) {
        guard let text = sender.text else { return }
        
        switch sender {
        case newPasswordTextField:
            print("DEBUG: test")
//            viewModel.name = text
        case reNewPasswordTextField:
            print("DEBUG: test")
//            viewModel.cellPhone = text
        default:
            print("DEBUG: default in switch Statement...")
        }
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
        newPasswordTextField.setDimensions(height: tfHeight, width: tfWidth)
        newPasswordTextField.centerX(inView: view)
        newPasswordTextField.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                                    paddingTop: view.frame.height * 0.1)
        
        view.addSubview(reNewPasswordTextField)
        setupTextField(reNewPasswordTextField, placehoder: "새 비밀번호 재입력", leftView: rePasswordleftView)
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
    

}


// MARK: - API

extension NewPasswordVC {
    func didSucceedCertificationNumber(response: ByPhoneResponse) {
        guard let key = response.key else { return }
//        viewModel.receivedKey = key
        print("DEBUG: key is \(key)...")
    }
}

// MARK: - Vaildation

extension NewPasswordVC {
    
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
