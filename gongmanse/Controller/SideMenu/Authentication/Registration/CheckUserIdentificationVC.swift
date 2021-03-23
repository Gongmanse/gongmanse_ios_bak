//
//  CheckUserIdentificationVC.swift
//  gongmanse
//
//  Created by 김우성 on 2021/03/22.
//

import UIKit
import Alamofire

class CheckUserIdentificationVC: UIViewController {

    // MARK: - Propertise
    
    var userInfoData = RegistrationInput(username: "woosungs", password: "", confirm_password: "", first_name: "", nickname: "", phone_number: 0, verification_code: 0, email: "", address1: "", address2: "", city: "", zip: 0, country: "")

    // MARK: - IBOutlet
    
    @IBOutlet weak var phoneNumberTextField: SloyTextField!
    @IBOutlet weak var certificationNumberTextField: SloyTextField!
    @IBOutlet weak var totalProgressView: UIView!
    @IBOutlet weak var currentProgressView: UIView!
    @IBOutlet weak var pageID: UILabel!
    @IBOutlet weak var pageNumber: UILabel!
    
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cofigureNavi()
        configureUI()
    }

    // MARK: - Actions
    
    @objc func handleSendingBtn() {
        // TODO: Alamofire 통신으로 인증번호를 받는 로직 구현
        // TODO: Timer 실행
        print("DEBUG: Clicked Button")
    }
    
    @IBAction func testAction(_ sender: Any) {
//        RegistrationDataManager().signUp(self.userInfoData, viewController: self)
        self.navigationController?.pushViewController(RegistrationCompletionVC(), animated: false)
    }
    
    func cofigureNavi() {
        // 내비게이션 타이틀 폰트 변경
        let title = UILabel()
        title.text = "회원가입"
        title.font = UIFont.appBoldFontWith(size: 17)
        navigationItem.titleView = title
    }

    func configureUI() {
        
        let tfWidth = view.frame.width - 125
        
        // 휴대전화번호 RightView
        // "인증번호 발송" 버튼 (이메일 TextField의 rightView)
        let buttonView = UIView(frame: CGRect(x: 0, y: 10, width: 80, height: 25))
        
        let sendingNumButton = UIButton(type: .system)
        sendingNumButton.setTitle("인증번호 발송", for: .normal)
        sendingNumButton.titleLabel?.font = UIFont.appBoldFontWith(size: 11)
        sendingNumButton.titleLabel?.tintColor = .white
        sendingNumButton.backgroundColor = .mainOrange
        sendingNumButton.layer.cornerRadius = 7
        sendingNumButton.frame = CGRect(x: 0, y: 5, width: 80, height: 25)
        buttonView.addSubview(sendingNumButton)
        sendingNumButton.addTarget(self, action: #selector(handleSendingBtn), for: .touchUpInside)
        phoneNumberTextField.rightView = buttonView
        phoneNumberTextField.rightViewMode = .always
        
        // 휴대전화번호 TextField
        let phoneNumberLeftView = settingLeftViewInTextField(phoneNumberTextField, #imageLiteral(resourceName: "myActivity"))
        phoneNumberTextField.setDimensions(height: 50, width: tfWidth)
        phoneNumberTextField.placeholder = "휴대전화 번호"
        phoneNumberTextField.leftViewMode = .always
        phoneNumberTextField.leftView = phoneNumberLeftView
        phoneNumberTextField.keyboardType = .numberPad
        phoneNumberTextField.centerX(inView: view)
        phoneNumberTextField.anchor(top: totalProgressView.bottomAnchor,
                           paddingTop: view.frame.height * 0.05)
        
        // 인증번호 RightView
        let timerView = UIView(frame: CGRect(x: 0, y: 0, width: 31, height: 13))
        
        let timerLabel = UILabel()
        timerLabel.text = "03:00"
        timerLabel.font = UIFont.appRegularFontWith(size: 10)
        timerLabel.textColor = .black
        
        timerLabel.frame = CGRect(x: 0, y: 10, width: 31, height: 13)
        timerView.addSubview(timerLabel)

        certificationNumberTextField.rightView = timerView
        certificationNumberTextField.rightViewMode = .always
        
        
        // 인증번호 TextField
        let certificationNumberTextFieldLeftView = settingLeftViewInTextField(phoneNumberTextField, #imageLiteral(resourceName: "myActivity"))
        certificationNumberTextField.setDimensions(height: 50, width: tfWidth)
        certificationNumberTextField.placeholder = "인증번호"
        certificationNumberTextField.leftViewMode = .always
        certificationNumberTextField.leftView = certificationNumberTextFieldLeftView
        certificationNumberTextField.keyboardType = .numberPad
        certificationNumberTextField.centerX(inView: view)
        certificationNumberTextField.anchor(top: phoneNumberTextField.bottomAnchor,
                           paddingTop: view.frame.height * 0.01)
        
        
        // ProgressView 오토레이아웃
        totalProgressView.centerX(inView: view)
        totalProgressView.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                                 left: view.leftAnchor,
                                 right: view.rightAnchor,
                                 height: 4)
        totalProgressView.backgroundColor = UIColor(white: 200.0 / 255.0, alpha: 1.0)
        
        currentProgressView.setDimensions(height: 4, width: view.frame.width * 0.75)
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
    }
    
    
}



// MARK: - 회원가입API

extension CheckUserIdentificationVC {
    func didSuccessRegistration(message: RegistrationResponse) {
        // TODO: 회원가입 성공 시, 진행할 로직 작성할 것.
        print("DEBUG: 회원가입이 성공했습니다.")
    }
    
    func failedToRequest(message: RegistrationResponse) {
        // TODO: 회원가입 실패 시, 진행할 로직 작성할 것.
        print("DEBUG: 회원가입이 실패했습니다.")
        print("DEBUG: message is \(message.message)")
        print("DEBUG: errors is \(message.errors!)")
    }
}
