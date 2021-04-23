//
//  FindIDByEmailVC.swift
//  gongmanse
//
//  Created by 김우성 on 2021/03/19.
//
// 아이디찾기 > 이메일로 찾기

import UIKit

class FindIDByEmailVC: UIViewController {

    // MARK: - Properties
    
    var viewModel = FindingPwdViewModel()
    
    var vTimer: Timer?          // 인증번호 타이머
    var totalTime: Int = 180    // 인증번호 시작 03:00
    
    var upperLabel: UILabel!
    var pageIndex: Int!

    // MARK: CodeUI
    // "인증번호 발송" 버튼 (rightView로 구현 시, 일부 영역이 클릭이 안되는 문제발생)
    private let sendingNumButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("인증번호 발송", for: .normal)
        button.titleLabel?.font = UIFont.appBoldFontWith(size: 11)
        button.titleLabel?.tintColor = .white
        button.backgroundColor = .mainOrange
        button.layer.cornerRadius = 7
        return button
    }()
    
    let timerLabel: UILabel = {
        let label = UILabel()
        label.text = "03:00"
        label.font = UIFont.appRegularFontWith(size: 10)
        label.textColor = .black
        return label
    }()
    
    // "완료" 버튼
    private let completeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("완료", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .gray
        return button
    }()
    
    // MARK: IBOutlet
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var certificationNumberTextField: UITextField!

    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureNotificationObservers()
    }

    // MARK: - Actions
    
    @objc func handleDismiss() {
        self.navigationController?.popViewController(animated: true)
    }
    
    // 완료 버튼 클릭 시, 호출되는 콜백메소드
    @objc func handleComplete() {
        if viewModel.formIsValid { // 인증번호가 사용자가 타이핑한 숫자와 일치하는 경우
            // Transition Controller
            let vc = FindIDResultVC()
            vc.viewModel = self.viewModel
            self.navigationController?.pushViewController(vc, animated: false)
        } else {
            presentAlert(message: "기입한 정보를 확인해주세요.")
        }
    }
    
    
    // MARK: - Helpers
    
    func configureUI() {
        /* UITextField Properties and LeftView */
        // 크기 비율
        let tfWidth = Constant.width * 0.73
        let tfHeight = Constant.height * 0.06
        
        // 이름 TextField leftView
        let nameImage = #imageLiteral(resourceName: "idOn")
        let nameleftView = UIView(frame: CGRect(x: 0, y: 10, width: 20, height: 20))
        let nameImageView = UIImageView(frame: CGRect(x: 0, y: 10, width: 20, height: 20))
        nameImageView.image = nameImage
        nameleftView.addSubview(nameImageView)
        
        // 이메일 TextField leftView
        let emailImage = #imageLiteral(resourceName: "emailOn")
        let emailLeftView = UIView(frame: CGRect(x: 0, y: 10, width: 20, height: 20))
        let emailImageView = UIImageView(frame: CGRect(x: 0, y: 10, width: 20, height: 20))
        emailImageView.image = emailImage
        emailLeftView.addSubview(emailImageView)
        
        // 인증번호 TextField leftView
        let certificationImage = #imageLiteral(resourceName: "authOn")
        let certificationleftView = UIView(frame: CGRect(x: 0, y: 10, width: 20, height: 20))
        let certificationimageView = UIImageView(frame: CGRect(x: 0, y: 10, width: 20, height: 20))
        certificationimageView.image = certificationImage
        certificationleftView.addSubview(certificationimageView)
        
        /* UITextField setting */
        // 이름 TextField
        nameTextField.setDimensions(height: tfHeight, width: tfWidth)
        setupTextField(nameTextField, placehoder: "이름", leftView: nameleftView)
        nameTextField.centerX(inView: view)
        nameTextField.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                             paddingTop: 20)
        
        // 이메일 TextField
        emailTextField.setDimensions(height: tfHeight, width: tfWidth)
        setupTextField(emailTextField, placehoder: "이메일", leftView: emailLeftView)
        emailTextField.centerX(inView: view)
        emailTextField.anchor(top: nameTextField.bottomAnchor,
                             paddingTop: 20)
        
        // "인증번호 발송" 버튼 (UIButton)
        sendingNumButton.addTarget(self, action: #selector(onTimerStart), for: .touchUpInside)
        view.addSubview(sendingNumButton)
        sendingNumButton.setDimensions(height: 25, width: 80)
        sendingNumButton.anchor(bottom: emailTextField.bottomAnchor,
                                right: emailTextField.rightAnchor,
                                paddingBottom: 10)
        
        // 인증번호 TextField
        certificationNumberTextField.setDimensions(height: tfHeight, width: tfWidth)
        setupTextField(certificationNumberTextField, placehoder: "인증번호", leftView: certificationleftView)
        certificationNumberTextField.keyboardType = .numberPad
        certificationNumberTextField.centerX(inView: view)
        certificationNumberTextField.anchor(top: emailTextField.bottomAnchor,
                             paddingTop: 20)
        
        // "03:00" UILabel (인증번호 TextField의 rightView)
        let timerView = UIView(frame: CGRect(x: 0, y: 0, width: 31, height: 13))
        timerLabel.frame = CGRect(x: 0, y: 10, width: 31, height: 13)
        timerView.addSubview(timerLabel)

        certificationNumberTextField.rightView = timerView
        certificationNumberTextField.rightViewMode = .always
        
        // "완료" UIButton
        view.addSubview(completeButton)
        completeButton.setDimensions(height: 40, width: 260)
        completeButton.layer.cornerRadius = 10
        completeButton.centerX(inView: view)
        completeButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor,
                              paddingBottom: 20)
        completeButton.addTarget(self, action: #selector(handleComplete), for: .touchUpInside)
        }
    }
    
    
    
    



// MARK: - Timer

private extension FindIDByEmailVC {

    /** 타이머 시작버튼 클릭 */
    @objc func onTimerStart(_ sender: Any) {
        
        if viewModel.name.count > 1 && viewModel.email.count > 4 {
            
            if let timer = vTimer {
                //timer 객체가 nil 이 아닌경우에는 invalid 상태에만 시작한다.
                if !timer.isValid {
                    /** 1초마다 timerCallback함수를 호출하는 타이머 */
                    vTimer = Timer.scheduledTimer(timeInterval: 1,
                                                  target: self,
                                                  selector: #selector(timerCallback),
                                                  userInfo: nil,
                                                  repeats: true)
                } else {    // 타이머 실행중에 다시 타이머를 실행했다면, 기존의 타이머를 멈추고 난 후, 실행한다.
                    timer.invalidate()
                    self.totalTime = 180
                    self.sendingNumButton.setTitle("재발송", for: .normal)
                    vTimer = Timer.scheduledTimer(timeInterval: 1,
                                                  target: self,
                                                  selector: #selector(timerCallback),
                                                  userInfo: nil,
                                                  repeats: true)
                }
            }else{
                //timer 객체가 nil 인 경우에 객체를 생성하고 타이머를 시작한다.
                /** 1초마다 timerCallback함수를 호출하는 타이머 */
                vTimer = Timer.scheduledTimer(timeInterval: 1,
                                              target: self,
                                              selector: #selector(timerCallback),
                                              userInfo: nil,
                                              repeats: true)
            }
            
            let inputData = ByEmailInput(receiver_type: "email",
                                         receiver: "\(viewModel.email)",
                                         name: "\(viewModel.name)")
            FindingIDDataManager().certificationNumberByEmail(inputData,
                                                              viewController: self)
        }
    }
    
    /** 타이머 종료버튼 클릭 */
    func onTimerEnd(_ sender: Any) {
        if let timer = vTimer {
            if(timer.isValid){
                timer.invalidate()
            }
        }
        totalTime = 0
    }
    
    //타이머가 호출하는 콜백함수
    @objc func timerCallback(){
        totalTime -= 1                                                      // 시작이 180초로 1초씩 감소하기위해 -1
        let dici = Int(Double((totalTime % 60) - (totalTime % 10)) * 0.1)   // 10초 단위 레이블 나타내기 위한 식
        timerLabel.text = "0\(Int(totalTime/60)):\(dici)\(totalTime%10)"    // 00:00 레이블
        
        if totalTime < 1 {
            timerLabel.text = "03:00"
            vTimer?.invalidate()
        }
    }
}


// MARK: - API

extension FindIDByEmailVC {
    
    /// 네트워크 통신에 성공하면 호출되는 메소드
    /// - 회원정보가 있는 경우 : 웹로그와 함께 인증번호가 넘어옴. 그래서 아래와 같이 정규표현식을 통해 값을 추출한다.
    /// - 회원정보가 없는 경우 : "message" : 텍스트... 이런식으로 넘어옴. 이때는 데이터를 또 가져와야한다.
    func didSucceed(response: String) { // response 값에 서버 로그와 key:123456 이 함께 전달됨.
        let findIndex = response.firstIndex(of: "\"")!      // " 가 사용된 첫번째 텍스트 부터
        let lastIndex = response.lastIndex(of: "}")!        // } 가 사용된 마지막 텍스트 까지
        let responseData = response[findIndex..<lastIndex]   // 위 조건 텍스트를 저장
        
        // 정규표현식을 통해서 {"key":숫자6자리} 만 필터링해보자.
        let filteredData = self.matches(for: "[0-9]{1}", in: String(responseData)) // ["4", "2", ...]
        
        var result = 0 // 인증번호를 저장한 프로퍼티
        var count = 0  // 자리수를 위한 인덱스
        var digit = 0  // 자리수(10의 거듭제곱) * 인자(1~9)
        
        for num in filteredData {
            count += 1
            digit = Int(self.power_for(x: 10, n: (6 - count)))
            result += (digit * Int(num)!)
        }
        print("DEBUG: result is \(result)...")
        viewModel.receivedKey = result
        
        if response.contains("입력하신 정보") {
            presentAlert(message: "입력하신 정보가 회원정보와 일치하지 않습니다.")
        }
    }
    
    func didFaild(response: String) {
        presentAlert(message: "네트워크 상태를 확인해주세요.")
        vTimer?.invalidate()
    }

}


// MARK: - UITextField

private extension FindIDByEmailVC {
    // 텍스트필드 콜벡메소드
    @objc func textDidChange(sender: UITextField) {
        guard let text = sender.text else { return }
        
        switch sender {
        case nameTextField:
            viewModel.name = text
        case emailTextField:
            viewModel.email = text
        case certificationNumberTextField:
            viewModel.certificationNumber = Int(text) ?? 0
            print("DEBUG: typing is \(Int(text))")
            
            // 입력값이 nil 일 때, .gray 입력값이 있다면, .mainOrange
            completeButton.backgroundColor = textFieldNullCheck(sender) ? .mainOrange : .gray
            
        default:
            print("DEBUG: default in switch Statement...")
        }
    }
    
    func textFieldNullCheck(_ tf: UITextField) -> Bool { // Null Check 커스텀메소드
        if tf.text == "" {
            return false
        } else { return true }
    }
    
    // 텍스트필드에 콜벡메소드 추가
    func configureNotificationObservers() {
        nameTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        emailTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        certificationNumberTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
    }
}

// MARK: - TapGesture

private extension FindIDByEmailVC {
    
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
