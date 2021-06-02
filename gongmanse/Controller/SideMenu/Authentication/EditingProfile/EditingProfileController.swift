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
    let imagePickerController = UIImagePickerController()
    var willChangeProfileImage: UIImage?
    
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
        view.backgroundColor = .white
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
        button.backgroundColor = .mainOrange
        button.addTarget(self, action: #selector(tapCompleteButton), for: .touchUpInside)
        return button
    }()

    // Validation 조건을 위한 UILabel
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
        
        networkingAPI()
        setupLayout()
        configureBottomLabel()
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
            passwordBottomLabel.alpha = viewModel.passwordIsValid ? 0 : 1
            
        case confirmPasswordTextField:
            viewModel.confirmPassword = text
            confirmPasswrodBottomLabel.alpha = viewModel.confirmPasswrdIsVaild ? 0 : 1
            
        case nameTextField:
            viewModel.username = text
            
        case nicknameTextField:
            viewModel.nickname = text
            nicknameBottomLabel.alpha = viewModel.nicknameIsValid ? 0 : 1
            
        case emailTextField:
            viewModel.email = text
            emailBottomLabel.alpha = viewModel.emailIsValid ? 0 : 1
            
        default:
            print("DEBUG: default in switch Statement...")
        }
        
        completeButton.backgroundColor = viewModel.buttonBackgroundColor
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
    
    @objc func tapCompleteButton() {
        print("DEBUG: 완료버튼을 클릭했습니다.")
        
        // 비밀번호 변경 API를 호출한다.
        // 유의 API에서 ID를 username 이라고 하고 있음.
        if viewModel.passwordIsValid {
            let changedPassword = ChangePasswordInput(username: viewModel.username,
                                                      password: viewModel.password)
            UpdateProfileImageDataManager().changePassword(changedPassword,
                                                       viewController: self)
        }
        
        if viewModel.emailIsValid {
            if viewModel.nickname.count > 2 {
                
                let inputData = changeNicknameAndEmailInput(token: Constant.token,
                                                            nickname: viewModel.nickname,
                                                            email: viewModel.email)
                UpdateProfileImageDataManager().changeNicknameAndEmail(inputData,
                                                                       viewController: self)
            }
        }
        navigationController?.popViewController(animated: true)
    }
    
    @objc func tapProfileImage(_ sender: UITapGestureRecognizer) {
        imagePickerController.sourceType = .photoLibrary
        present(imagePickerController, animated: true, completion: nil)
    }

    
    // MARK: - Heleprs
    
    func networkingAPI() {
        
        let inputData = EditingProfileInput(token: Constant.token)
        EditingProfileDataManager().getProfileInfoFromAPI(inputData,
                                                          viewController: self)
    }
    
    
    func setupLayout() {

        view.backgroundColor = .white
        imagePickerController.delegate = self
        
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
        profileImageView.clipsToBounds = true
        profileImageView.layer.cornerRadius = profileImageConstant * 0.5
        
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
        passwordTextField.isSecureTextEntry = true
        setupTextField(passwordTextField, placehoder: "비밀번호", leftView: passwordLeftView)
        passwordTextField.setDimensions(height: tfHeight, width: tfWidth)
        passwordTextField.centerX(inView: view)
        passwordTextField.anchor(top: idTextField.topAnchor,
                             paddingTop: verticalPadding)
        
        view.addSubview(confirmPasswordTextField)
        confirmPasswordTextField.isSecureTextEntry = true
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
        
        
        profileImageContainerView.isUserInteractionEnabled = true
        let profileImageTapGesture = UITapGestureRecognizer(target: self, action: #selector(tapProfileImage))
        profileImageContainerView.addGestureRecognizer(profileImageTapGesture)

    }
    
    // MARK: 텍스트필드 하단 레이블 UI
    func configureBottomLabel() {
        let tfWidth = view.frame.width - 125

        // 비밀번호 하단 레이블
        view.addSubview(passwordBottomLabel)
        passwordBottomLabel.setDimensions(height: 10, width: tfWidth)
        passwordBottomLabel.anchor(top: passwordTextField.bottomAnchor,
                           left: passwordTextField.leftAnchor,
                           paddingTop: 3,
                           paddingLeft: 5)
        // 비밀번호 재입력 하단 레이블
        view.addSubview(confirmPasswrodBottomLabel)
        confirmPasswrodBottomLabel.setDimensions(height: 10, width: tfWidth)
        confirmPasswrodBottomLabel.anchor(top: confirmPasswordTextField.bottomAnchor,
                                          left: confirmPasswordTextField.leftAnchor,
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
}


// MARK: - API

extension EditingProfileController {
    
    // 21.06.02
    // TODO: 비밀번호 변경 -> OK
    // TODO: 닉네임 및 이메일 변경 ( 같은 API에서 한번에 변경하고 있음) -> OK
    // TODO: 프로필 사진 변경 -> MultiformData 이용해서 실제 이미지 파일을 넣어야함. -> OK
    
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
        
        // "01010. 프로필 정보 조회" API에서 데이터를 받는다.
        // 받아온 데이터
        let receivedData = response
        let id = receivedData.sUsername
        let name = receivedData.sFirstName
        let nickname = receivedData.sNickname
        let email = receivedData.sEmail
        var profileImageURL = String()
        if let imageURL = receivedData.sImage {
            profileImageURL = "https://file.gongmanse.com/" + imageURL
        }
        
        // UI에 데이터를 입력한다.
        /*
         21.06.02 작성
         - 프로필 이미지 변경 시, .png 로 입력한다.
         - 프로필 전체정보 중에서 이미지는 String(URL)로 준다.
         - 프로필이미지파일을 주면 서버에서 URL로 변환해주어야 한다고 생각한다.
         - 프로펄 이미지 변경 시, API Response는 정상적으로 되었다고 하고 있으나
         다시 프로필 정보조회를 하면 변경되어있지 않다.
         1. DB에서 저장기능이 이상하거나
         2. 프로필 이미니 넣는 방식이 잘못되었거나
         추후 진행예정
        */
        
        profileImageView.sd_setImage(with: URL(string: profileImageURL), completed: nil)
        idTextField.text = id
        nameTextField.text = name
        nicknameTextField.text = nickname
        viewModel.nickname = nickname
        emailTextField.text = email
        viewModel.email = email
    }
    
    
    func didSuccessChangePassword(response: ChangePasswordResponse) {
        print("DEBUG: 비밀번호 변경되면 이 메소드를 호출합니다. ", #function)
    }
    
    func didSuccessUpdateProfileImage(response: UpdateProfileImageResponse) {
        print("DEBUG: 성공메세지 \(response.message)")
        profileImageView.image = willChangeProfileImage
    }
}


extension EditingProfileController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
 
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[UIImagePickerController.InfoKey.originalImage] {
            profileImageView.image = image as! UIImage
            willChangeProfileImage = image as! UIImage
        }
        dismiss(animated: true) {
            
            // "01011. 프로필 이미지 수정" API 내가 선택한 이미지를 POST 한다.
            if let selectedProfileImage = self.willChangeProfileImage {
                let imageData = selectedProfileImage.pngData()!
                
                let inputProfileData = UpdateProfileImageInput(file: imageData,
                                                               token: Constant.token)
                UpdateProfileImageDataManager().changeProfileImage(inputProfileData,
                                                                   viewController: self)
                
                /*
                 21.06.02 작성
                 - 프로필 이미지 변경 시, .png 로 입력한다.
                 - 프로필 전체정보 중에서 이미지는 String(URL)로 준다.
                 - 프로필이미지파일을 주면 서버에서 URL로 변환해주어야 한다고 생각한다.
                 - 프로펄 이미지 변경 시, API Response는 정상적으로 되었다고 하고 있으나
                 다시 프로필 정보조회를 하면 변경되어있지 않다.
                 1. DB에서 저장기능이 이상하거나
                 2. 프로필 이미니 넣는 방식이 잘못되었거나
                 추후 진행예정
                */
            }
        }
    }
}
