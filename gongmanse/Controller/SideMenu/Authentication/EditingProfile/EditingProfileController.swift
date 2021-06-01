//
//  EditingProfileController.swift
//  gongmanse
//
//  Created by 김우성 on 2021/06/01.
//

import UIKit

class EditingProfileController: UIViewController {
    
    // MARK: - Properties
    
    /// 프로필 이미지
    let profileImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = #imageLiteral(resourceName: "idOff")
        return imageView
    }()
    
    let pictureImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .bottomRight
        imageView.image = #imageLiteral(resourceName: "pictureEditButton")
        return imageView
    }()
    
    let profileImageContainerView: UIView = {
        let view = UIView()
        return view
    }()
    
    private let idTextField = SloyTextField()
    private let passwordTextField = SloyTextField()
    private let confirmPasswordTextField = SloyTextField()
    private let nameTextField = SloyTextField()
    private let nicknameTextField = SloyTextField()
    private let emailTextField = SloyTextField()

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
        
        setupLayout()
    }
    
    
    // MARK: - Actions
    
    // 텍스트필드 콜벡메소드
    @objc func textDidChange(sender: UITextField) {
        guard let text = sender.text else { return }
        
        switch sender {
        case idTextField:
            print("DEBUG: 123")
        case passwordTextField:
            print("DEBUG: 123")
        case confirmPasswordTextField:
            print("DEBUG: 123")
        case nameTextField:
            print("DEBUG: 123")
        case nicknameTextField:
            print("DEBUG: 123")
        case emailTextField:
            print("DEBUG: 123")
        default:
            print("DEBUG: default in switch Statement...")
        }
    }
    
    // 텍스트필드에 콜벡메소드 추가
    func configureNotificationObservers() {

        idTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        confirmPasswordTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        nameTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        nicknameTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        emailTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
    }
    
    /// 완료 버튼 클릭 시, 호출되는 콜백메소드
    @objc func handleComplete() {
        
//        if viewModel.formIsValid { // 인증번호가 사용자가 타이핑한 숫자와 일치하는 경우
//            // Transition Controller
//            let vc = NewPasswordVC()
//             vc.viewModel.username = self.viewModel.name
//            self.navigationController?.pushViewController(vc, animated: true)
//
//        } else {
//            presentAlert(message: "기입한 정보를 확인해주세요.")
//        }
        
    }
    
    // MARK: - Heleprs
    
    func setupLayout() {
        
        view.backgroundColor = .white
        
        // 크기 비율
        let verticalPadding = view.frame.height * 0.077
        let tfWidth = Constant.width * 0.73
        let tfHeight = Constant.height * 0.06
        let profileImageConstant = view.frame.height * 0.1
        let viewWidth = view.frame.width
        
        // leftView - 추후에 각각의 텍스트 필드에 맞는 이미지로 변경할 것.
        let idleftView = addLeftView(image: #imageLiteral(resourceName: "idOn"))
        let passwordLeftView = addLeftView(image: #imageLiteral(resourceName: "passwordOn"))
        let confirmPasswordLeftView = addLeftView(image: #imageLiteral(resourceName: "passwordOn"))
        let nameleftView = addLeftView(image: #imageLiteral(resourceName: "nameOn"))
        let nicknameLeftView = addLeftView(image: #imageLiteral(resourceName: "nicknameOn"))
        let emailLeftView = addLeftView(image: #imageLiteral(resourceName: "emailOn"))
    
        
        // 오토레이아웃 적용
        view.addSubview(profileImageContainerView)
        profileImageContainerView.backgroundColor = .clear
        profileImageContainerView.setDimensions(height: profileImageConstant,
                                                width: profileImageConstant)
        profileImageContainerView.centerX(inView: view)
        profileImageContainerView.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                                         paddingTop: viewWidth * 0.11)
        
        profileImageContainerView.addSubview(profileImage)
        profileImage.addShadow()
        profileImage.setDimensions(height: profileImageConstant,
                                   width: profileImageConstant)
        profileImage.layer.cornerRadius = profileImageConstant * 0.5
        profileImage.backgroundColor = UIColor.rgb(red: 237, green: 237, blue: 237)
        profileImage.centerX(inView: profileImageContainerView)
        profileImage.centerY(inView: profileImageContainerView)
        
        profileImageContainerView.addSubview(pictureImage)
        pictureImage.setDimensions(height: 50,
                                   width: 50)
        pictureImage.anchor(bottom: profileImageContainerView.bottomAnchor,
                            right: profileImageContainerView.rightAnchor,
                            paddingBottom: -15,
                            paddingRight: -15)
        
        view.addSubview(idTextField)
        setupTextField(idTextField, placehoder: "아이디", leftView: idleftView)
        idTextField.setDimensions(height: tfHeight, width: tfWidth)
        idTextField.centerX(inView: view)
        idTextField.anchor(top: profileImageContainerView.topAnchor,
                             paddingTop: verticalPadding + 30)
        
        view.addSubview(passwordTextField)
        setupTextField(passwordTextField, placehoder: "비밀번호", leftView: passwordLeftView)
        passwordTextField.setDimensions(height: tfHeight, width: tfWidth)
        passwordTextField.centerX(inView: view)
        passwordTextField.anchor(top: idTextField.topAnchor,
                             paddingTop: verticalPadding)
        
        view.addSubview(confirmPasswordTextField)
        setupTextField(confirmPasswordTextField, placehoder: "비밀번호 재입력", leftView: confirmPasswordLeftView)
        confirmPasswordTextField.setDimensions(height: tfHeight, width: tfWidth)
        confirmPasswordTextField.centerX(inView: view)
        confirmPasswordTextField.anchor(top: passwordTextField.topAnchor,
                             paddingTop: verticalPadding)
        
        view.addSubview(nameTextField)
        setupTextField(nameTextField, placehoder: "이름", leftView: nameleftView)
        nameTextField.setDimensions(height: tfHeight, width: tfWidth)
        nameTextField.centerX(inView: view)
        nameTextField.anchor(top: confirmPasswordTextField.topAnchor,
                             paddingTop: verticalPadding)
        
        view.addSubview(nicknameTextField)
        setupTextField(nicknameTextField, placehoder: "닉네임", leftView: nicknameLeftView)
        nicknameTextField.setDimensions(height: tfHeight, width: tfWidth)
        nicknameTextField.centerX(inView: view)
        nicknameTextField.anchor(top: nameTextField.topAnchor,
                             paddingTop: verticalPadding)
        
        view.addSubview(emailTextField)
        setupTextField(emailTextField, placehoder: "이메일", leftView: emailLeftView)
        emailTextField.setDimensions(height: tfHeight, width: tfWidth)
        emailTextField.centerX(inView: view)
        emailTextField.anchor(top: nicknameTextField.topAnchor,
                             paddingTop: verticalPadding)
        
        view.addSubview(completeButton)
        completeButton.setDimensions(height: 40, width: 260)
        completeButton.layer.cornerRadius = 10
        completeButton.centerX(inView: view)
        completeButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor,
                              paddingBottom: 20)
        completeButton.addTarget(self, action: #selector(handleComplete), for: .touchUpInside)
    }
    
}
