//
//  EditingProfileController.swift
//  gongmanse
//
//  Created by 김우성 on 2021/06/01.
//

import UIKit
import SDWebImage

class EditingProfileController: UIViewController {
    
    // MARK: - Properties
    var viewModel = EditingProfileViewModel()
    
    /// 프로필 이미지
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = #imageLiteral(resourceName: "idOff")
        return imageView
    }()
    
    let pictureImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .bottomRight
        imageView.image = #imageLiteral(resourceName: "pictureEditButton")
        return imageView
    }()
    
    let profileImageContainerView: UIView = {
        let view = UIView()
        return view
    }()
    
    // 아이디와 이름은 변경 불가능하게 하기 위한 View (반투명 검정View)
    private let blockViewForID: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.15)
        view.clipsToBounds = true
        view.layer.cornerRadius = 5
        view.layer.maskedCorners = CACornerMask(arrayLiteral: .layerMinXMinYCorner, .layerMaxXMinYCorner)
        return view
    }()
    
    private let blockViewForName: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.15)
        view.clipsToBounds = true
        view.layer.cornerRadius = 5
        view.layer.maskedCorners = CACornerMask(arrayLiteral: .layerMinXMinYCorner, .layerMaxXMinYCorner)
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
        
        networkingAPI()
        setupLayout()
        configureNotificationObservers()
    }
    
    
    // MARK: - Actions
    
    // 텍스트필드 콜벡메소드
    @objc func textDidChange(sender: UITextField) {
        guard let text = sender.text else { return }
        
        switch sender {
        case idTextField:
            print("DEBUG: 아이디 텍스트필드는 클릭을 할 수 없습니다.")
        case passwordTextField:
            viewModel.password = text

        case confirmPasswordTextField:
            viewModel.confirmPassword = text
            
        case nameTextField:
            viewModel.username = text
            
        case nicknameTextField:
            viewModel.nickname = text
            
        case emailTextField:
            viewModel.email = text
            
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
    
    @objc func tapBackButton() {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Heleprs
    
    func networkingAPI() {
        
        let inputData = EditingProfileInput(token: Constant.token)
        EditingProfileDataManager().getProfileInfoFromAPI(inputData,
                                                          viewController: self)
    }
    
    
    func setupLayout() {
        
        view.backgroundColor = .white
        self.navigationItem.title = "프로필 편집"
        let leftBarButton = UIBarButtonItem(image: #imageLiteral(resourceName: "back"),
                                            style: .plain,
                                            target: self,
                                            action: #selector(tapBackButton))
        
        self.navigationItem.leftBarButtonItem = leftBarButton
        
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
        
        profileImageContainerView.addSubview(profileImageView)
        profileImageView.addShadow()
        profileImageView.setDimensions(height: profileImageConstant,
                                   width: profileImageConstant)
        profileImageView.layer.cornerRadius = profileImageConstant * 0.5
        profileImageView.backgroundColor = UIColor.rgb(red: 237, green: 237, blue: 237)
        profileImageView.centerX(inView: profileImageContainerView)
        profileImageView.centerY(inView: profileImageContainerView)
        
        profileImageContainerView.addSubview(pictureImageView)
        pictureImageView.setDimensions(height: 50,
                                   width: 50)
        pictureImageView.anchor(bottom: profileImageContainerView.bottomAnchor,
                            right: profileImageContainerView.rightAnchor,
                            paddingBottom: -15,
                            paddingRight: -15)
        
        view.addSubview(idTextField)
        setupTextField(idTextField, placehoder: "아이디", leftView: idleftView)
        idTextField.setDimensions(height: tfHeight, width: tfWidth)
        idTextField.centerX(inView: view)
        idTextField.anchor(top: profileImageContainerView.topAnchor,
                             paddingTop: verticalPadding + 30)
        
        view.addSubview(blockViewForID)
        blockViewForID.anchor(top: idTextField.topAnchor,
                              left: idTextField.leftAnchor,
                              bottom: idTextField.bottomAnchor,
                              right: idTextField.rightAnchor)
        
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
        
        view.addSubview(blockViewForName)
        blockViewForName.anchor(top: nameTextField.topAnchor,
                                left: nameTextField.leftAnchor,
                                bottom: nameTextField.bottomAnchor,
                                right: nameTextField.rightAnchor)
        
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


// MARK: - API

extension EditingProfileController {
    
    // TODO: 비밀번호 변경
    // TODO: 닉네임 및 이메일 변경 ( 같은 API에서 한번에 변경하고 있음)
    // TODO: 프로필 사진 변경 -> MultiformData 이용해서 실제 이미지 파일을 넣어야함.
    
    private func getImageFromURL(url: String) -> UIImage{
        
        var resultImage = UIImage()
        
        if let url = URL(string: url) {
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                guard let data = data, error == nil else { return }
                DispatchQueue.main.async {
                    resultImage = UIImage(data: data)!
                }
            }
            task.resume()
        }
        return resultImage
    }
    
    func didSuccessNetworing(response: EditingProfileResponse) {
        
        let receivedData = response
        let id = receivedData.sUsername
        let name = receivedData.sFirstName
        let nickname = receivedData.sNickname
        let email = receivedData.sEmail
        let profileImageURL = "https://file.gongmanse.com/" + receivedData.sImage
        profileImageView.sd_setImage(with: URL(string: profileImageURL), completed: nil)
        idTextField.text = id
        nameTextField.text = name
        nicknameTextField.text = nickname
        emailTextField.text = email
    }
    
    
    func didSuccessChangePassword(response: ChangePasswordResponse) {
        print("DEBUG: 비밀번호 변경되면 이 메소드를 호출합니다. ", #function)
    }
    
}


