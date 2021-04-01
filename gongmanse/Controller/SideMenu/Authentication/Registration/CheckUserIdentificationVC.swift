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
    var totalTime: Int = 180                        // 03:00 카운트를 위한 프로퍼티

    // 오류메세지 보여줄 View
    private let errorMessageView: UILabel = {
        let label = UILabel()
        label.backgroundColor = #colorLiteral(red: 0.202868529, green: 0.202868529, blue: 0.202868529, alpha: 1)
        label.textColor = .white
        label.alpha = 0
        return label
    }()
    
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
    
    private let verificationSendingBtn: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .gray
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
        guard let viewModel   = viewModel else { return }
        guard let phoneNumber = self.viewModel?.phone_number else { return }
        
        if viewModel.phoneNumberIsValid {   // phoneNumberTextField의 자리수가 11자리거니 13자리일 때만 로직 실행
            let input = phoneNumber.components(separatedBy: ["-"]).joined() // "-" 이 있는 경우 제거하는 로직
            // Alamofire 통신으로 인증번호를 받는 로직 구현
            CertificationDataManager().sendingNumber(CertificationNumberInput(phone_number: input), viewController: self)
            onTimerStart()  // 인증번호 유효기간 Timer 실행
        } else {
            print("DEBUG: 휴대전화 textField에 잘못된 값을 입력했습니다.")
        }
    }
    
    // "다음" 버튼 클릭 시, 호출되는 메소드
    @IBAction func nextPageAction(_ sender: Any) {
        guard let username =          self.viewModel?.username else { return }
        guard let password =          self.viewModel?.password else { return }
        guard let confirm_password =  self.viewModel?.confirm_password else { return }
        guard let first_name =        self.viewModel?.first_name else { return }
        guard let nickname =          self.viewModel?.nickname else { return }
        guard let phone_number =      self.viewModel?.phone_number else { return }
        guard let verification_code = self.viewModel?.verification_code else { return }
        guard let email =             self.viewModel?.email else { return }
        
        let userInfoData = RegistrationInput(username: "\(username)",
                                             password: "\(password)",
                                             confirm_password: "\(confirm_password)",
                                             first_name: "\(first_name)",
                                             nickname: "\(nickname)",
                                             phone_number: "\(phone_number)", // viewModel에서 휴대전화 "-" 제거 정규표현식 적용할 예정
                                             verification_code: verification_code,
                                             email: "\(email)", address1: "", address2: "", city: "", zip: 0, country: "")
   
        RegistrationDataManager().signUp(userInfoData, viewController: self)                        // 1) 회원가입을 위한 정보 전송
        numberTimer?.invalidate()                                                                   // 2) 타이머 종료
    }
    
    @objc func timerCallback() {
        totalTime -= 1                                                      // 시작이 180초로 1초씩 감소하기위해 -1
        let dici = Int(Double((totalTime % 60) - (totalTime % 10)) * 0.1)   // 10초 단위 레이블 나타내기 위한 식
        timerLabel.text = "0\(Int(totalTime/60)):\(dici)\(totalTime%10)"    // 00:00 레이블
        
        if totalTime < 1 {
            numberTimer?.invalidate()
        }
    }
    
    // MARK: - Helper functions
    
    func onTimerStart() {
        if let timer = numberTimer {
                   //timer 객체가 nil 이 아닌경우에는 invalid 상태에만 시작한다
                   if !timer.isValid {
                       /** 1초마다 timerCallback함수를 호출하는 타이머 */
                    numberTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerCallback), userInfo: nil, repeats: true)
                   }
               } else {
                   //timer 객체가 nil 인 경우에 객체를 생성하고 타이머를 시작한다
                   /** 1초마다 timerCallback함수를 호출하는 타이머 */
                numberTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerCallback), userInfo: nil, repeats: true)
               }
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
        
        // "인증번호 발송" 버튼 (이메일 TextField의 rightView)
        view.addSubview(verificationSendingBtn)
        verificationSendingBtn.setDimensions(height: 25, width: 80)
        verificationSendingBtn.anchor(bottom: phoneNumberTextField.bottomAnchor,
                          right: phoneNumberTextField.rightAnchor,
                          paddingBottom: 5.5)
        verificationSendingBtn.addTarget(self, action: #selector(handleSendingBtn), for: .touchUpInside)
        
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
        
        // 경고창 오토 레이아웃
        view.addSubview(errorMessageView)
        errorMessageView.setDimensions(height: 50,
                                       width: view.frame.width * 0.77)
        self.errorMessageView.centerX(inView: self.view)
        self.errorMessageView.centerY(inView: self.view)
        
        
    }
    
    
    // MARK: textField가 편집될 때마다 호출되는 콜백메소드
    @objc func textDidChange(sender: UITextField) {
        sender.tintColor = .mainOrange  // textField 커서 색상변경

        guard let text = sender.text else { return }

        switch sender {
        case phoneNumberTextField:
            self.viewModel?.phone_number = text
            verificationSendingBtn.backgroundColor = self.viewModel!.phoneNumberIsValid ? .mainOrange : .gray // 010-0000-0000 OR 01000000000 형식인 경우 true
        case certificationNumberTextField:
            // 인증번호가 String 타입인지 Int 타입인지에 따라서 코드 변경할 예정.
            self.viewModel?.verification_code = Int(text)
        default:
            print("DEBUG: switch Default")
        }
    
        // 버튼 색상 변경을 위한 로직
        guard let phoneValidation = self.viewModel?.phoneNumberIsValid else { return }
        guard let verificationNumberValidation = self.viewModel?.verificationNumberIsValid else { return }
        
        if phoneValidation && verificationNumberValidation {
            nextButton.backgroundColor = .mainOrange
        } else {
            nextButton.backgroundColor = .gray
        }
        
        #warning("추후 다시 진행예정.")
        /*
         인증번호 관련해서 API 새로 만들 우려가 있으므로 작업하던거 중지.
         현재 : 가입정보를 전송해야 가입된 휴대폰인지 결과를 알 수 있음
         개선한다면 : 휴대전화 인증번호 보낼때, 이미 가입된 휴대전화인지 결과를 알려준다.
        */
    }
        
    func configureNotificationObservers() {
        // addTarget
        phoneNumberTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        certificationNumberTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        }
}


// MARK: - 회원가입API

extension CheckUserIdentificationVC {
    func didSuccessRegistration(message: RegistrationResponse) {
        // 회원가입 성공할 경우, 화면전환
        self.navigationController?.pushViewController(RegistrationCompletionVC(), animated: false)
    }
    
    func failedToRequest(message: RegistrationResponse) {
        // TODO: 회원가입 실패 시, 진행할 로직 작성할 것.
        // 가입이 실패한 이유에 대해서 알려주어야하는 데, 알려주는 방법이 Alert인지 아니면 다른방법인지 안드로이드와 맞출 것.
        UIView.animate(withDuration: 0.33) {
            self.errorMessageView.alpha = 1
            self.errorMessageView.text = "\(message.message)"
        }
        
    
        
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
