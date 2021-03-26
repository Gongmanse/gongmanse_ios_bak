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
    
    var viewModel: RegistrationUserInfoViewModel?   // viewModel
    var numberTimer: Timer?                         // timer
    var totalTime: Int = 180                        // 3분
    
    
//    lazy var userInfoData = RegistrationInput(username: "\(viewModel!.username!)",
//                                              password: "\(viewModel!.password!)",
//                                              confirm_password: "\(viewModel!.confirm_password!)",
//                                              first_name: "\(viewModel!.first_name!)",
//                                              nickname: "\(viewModel!.nickname!)",
//                                              phone_number: viewModel!.phone_number!, // viewModel에서 휴대전화 "-" 제거 정규표현식 적용할 예정
//                                              verification_code: viewModel!.verification_code!,
//                                              email: "\(viewModel!.email!)", address1: "", address2: "", city: "", zip: 0, country: "")

    // 인증번호 RightView
    private let timerLabel: UILabel = {
        let label = UILabel()
        label.text = "03:00"
        label.font = UIFont.appRegularFontWith(size: 10)
        label.textAlignment = .right
        label.textColor = .black
        label.frame = CGRect(x: 0, y: 10, width: 50, height: 13)
        return label
    }()
    
    private let textButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .mainOrange
        button.setTitle("인증번호 발송", for: .normal)
        button.titleLabel?.font = UIFont.appRegularFontWith(size: 11)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        return button
    }()
    
    // MARK: IBOutlet
    @IBOutlet weak var phoneNumberTextField: SloyTextField!
    @IBOutlet weak var certificationNumberTextField: SloyTextField!
    @IBOutlet weak var totalProgressView: UIView!
    @IBOutlet weak var currentProgressView: UIView!
    @IBOutlet weak var pageID: UILabel!
    @IBOutlet weak var pageNumber: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cofigureNavi()
        configureUI()
        configureNotificationObservers()
    }

    // MARK: - Actions
    
    // "인증번호 발송" 클릭 시, 호출되는 메소드
    @objc func handleSendingBtn() {
        guard let viewModel = viewModel else { return }
        print("DEBUG: Clicked sendingButton...")
        
        // 만약 휴대전화번호를 입력하지 않았는데 클릭한 경우를 위해서 조건문 추가할 것.
        // Alamofire 통신으로 인증번호를 받는 로직 구현
//        CertificationDataManager().sendingNumber(CertificationNumberInput(phone_number: viewModel.phone_number!), viewController: self)
        onTimerStart()  // 인증번호 유효기간 Timer 실행
    }
    
    // "다음" 버튼 클릭 시, 호출되는 메소드
    @IBAction func nextPageAction(_ sender: Any) {
        guard let viewModel = viewModel else { return }
        
        let userInfoData = RegistrationInput(username: "\(viewModel.username!)",
                                             password: "\(viewModel.password!)",
                                             confirm_password: "\(viewModel.confirm_password!)",
                                             first_name: "\(viewModel.first_name!)",
                                             nickname: "\(viewModel.nickname!)",
                                             phone_number: viewModel.phone_number!, // viewModel에서 휴대전화 "-" 제거 정규표현식 적용할 예정
                                             verification_code: viewModel.verification_code!,
                                             email: "\(viewModel.email!)", address1: "", address2: "", city: "", zip: 0, country: "")
        
        // 1) 회원가입을 위한 정보를 모두 전송
        RegistrationDataManager().signUp(userInfoData, viewController: self)
        
        // 2) TODO: 만약 성공했다면 버튼 색상 변경과 다음페이지 이동 로직 구현
        numberTimer?.invalidate()
        // 3) 화면이동
        self.navigationController?.pushViewController(RegistrationCompletionVC(), animated: false)
    }
    
    @objc func timerCallback() {
        totalTime -= 1                                                      // 시작이 180초로 1초씩 감소하기위해 -1
        let dici = Int(Double((totalTime % 60) - (totalTime % 10)) * 0.1)   // 10초 단위 레이블 나타내기 위한 식
        timerLabel.text = "0\(Int(totalTime/60)):\(dici)\(totalTime%10)"    // 00:00 레이블
        
        if totalTime == 0 {
            numberTimer?.invalidate()
        }
    }
    
    // MARK: - Helper functions
    
    func onTimerStart() {
        // 1초마다 timerCallback 메소드 호출
        numberTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerCallback), userInfo: nil, repeats: true)
        
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
        nextButton.backgroundColor = UIColor.progressBackgroundColor
        
        // 휴대전화번호 RightView
        // "인증번호 발송" 버튼 (이메일 TextField의 rightView)
        
        view.addSubview(textButton)
        textButton.setDimensions(height: 25, width: 80)
        textButton.anchor(bottom: phoneNumberTextField.bottomAnchor,
                          right: phoneNumberTextField.rightAnchor,
                          paddingBottom: 5.5)
        textButton.addTarget(self, action: #selector(handleSendingBtn), for: .touchUpInside)
        
        
        
//        let buttonView = UIView(frame: CGRect(x: 0, y: 0, width: 80, height: 25))
//
//        let sendingNumButton = UIButton(type: .system)
//        sendingNumButton.setTitle("인증번호 발송", for: .normal)
//        sendingNumButton.titleLabel?.font = UIFont.appBoldFontWith(size: 11)
//        sendingNumButton.titleLabel?.tintColor = .white
//        sendingNumButton.backgroundColor = .mainOrange
//        sendingNumButton.layer.cornerRadius = 7
//        sendingNumButton.frame = CGRect(x: 0, y: 5, width: 80, height: 25)
//        buttonView.addSubview(sendingNumButton)
//        sendingNumButton.addTarget(self, action: #selector(handleSendingBtn), for: .touchUpInside)
//        phoneNumberTextField.rightView = buttonView
//        phoneNumberTextField.rightViewMode = .always
        
        // 휴대전화번호 TextField
        let phoneNumberLeftView = settingLeftViewInTextField(phoneNumberTextField, #imageLiteral(resourceName: "myActivity"))
        setupTextField(phoneNumberTextField, placehoder: "휴대전화 번호", leftView: phoneNumberLeftView)
        phoneNumberTextField.setDimensions(height: 50, width: tfWidth)
        phoneNumberTextField.anchor(top: totalProgressView.bottomAnchor,
                                    left: certificationNumberTextField.leftAnchor,
                           paddingTop: view.frame.height * 0.05)
        
        let timerView = UIView(frame: CGRect(x: 0, y: 0, width: 51, height: 13))
        timerView.addSubview(timerLabel)
        certificationNumberTextField.rightView = timerView
        certificationNumberTextField.rightViewMode = .always
        
        // 인증번호 TextField
        let certificationNumberTextFieldLeftView = settingLeftViewInTextField(phoneNumberTextField, #imageLiteral(resourceName: "myActivity"))
        certificationNumberTextField.setDimensions(height: 50, width: tfWidth)
        setupTextField(certificationNumberTextField, placehoder: "인증번호", leftView: certificationNumberTextFieldLeftView)
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
    
    @objc func textDidChange() {
        guard var viewModel = viewModel else { return }
        viewModel.phone_number = Int(phoneNumberTextField.text!.components(separatedBy: ["-"]).joined())    // 010-1111-1111 을 01011111111로 저장
        
        // textField의 값을 viewModel에 할당
        viewModel.phone_number = Int(viewModel.phone_number!)
        viewModel.verification_code = Int(certificationNumberTextField.text!)
        
        #warning("추후 다시 진행예정.")
        // 0326작성 -> 안드로이드 분들 출근하시는 날 확인할 것.
        // TODO: 텍스트필드에 인증번호를 작성할 때마다 인증번호API를 통해 인증번호를 검증해야하는 것인지 아니면 다음을 누를 때 검증해야하는 것인지 안드로이드 보고 판단할 것
    }
    
    // textField 공통 세팅 커스텀메소드
    private func setupTextField(_ tf: UITextField, placehoder: String, leftView: UIView) {
        tf.placeholder = placehoder
        tf.leftViewMode = .always
        tf.tintColor = .gray
        tf.leftView = leftView
        tf.keyboardType = .numberPad
    }
    
    func configureNotificationObservers() {
            // addTarget
            phoneNumberTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
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
    
    func didSendingNumber(response: CertificationNumberResponses) {
        // 인증번호 전송 시, 진행할 로직 작성할 것.
        // TODO: 정상적으로 API는 동작하는데, 실제 휴대폰으로 인증번호가 오지 않음.
        print("DEBUG: 정상적으로 인증번호 전송됨.")
        print("DEBUG: 인증번호id는 \(String(describing: response.data!)) 입니다.")
    }
    
}
