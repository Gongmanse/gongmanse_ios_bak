//
//  FindingPwdByEmailVC.swift
//  gongmanse
//
//  Created by 김우성 on 2021/03/23.
//

import UIKit

class FindingPwdByEmailVC: UIViewController {

    // MARK: - Properties
    
    var viewModel = FindingPwdViewModel()
        
    var pageIndex: Int! // 상단탭바 구현을 위한 프로퍼티
    var vTimer: Timer?          // 인증번호 타이머
    var totalTime: Int = 180    // 인증번호 시작 03:00
    
    private let nameTextField = SloyTextField()
    private let idTextField = SloyTextField()
    private let emailTextField = SloyTextField()
    private let certificationTextField = SloyTextField()
    
    // "완료" 버튼
    private let completeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("완료", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .progressBackgroundColor
        return button
    }()
    
    // "인증번호 발송" 버튼
    private let sendingNumButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("인증번호 발송", for: .normal)
        button.titleLabel?.font = UIFont.appBoldFontWith(size: 11)
        button.titleLabel?.tintColor = .white
        button.backgroundColor = .mainOrange
        button.layer.cornerRadius = 7
        return button
    }()
    
    // 인증번호 시간 보여주는 레이블
    private let timerLabel: UILabel = {
        let label = UILabel()
        label.text = "03:00"
        label.font = UIFont.appRegularFontWith(size: 10)
        label.textColor = .black
        return label
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
        if viewModel.formIsValid { // 인증번호가 사용자가 타이핑한 숫자와 일치하는 경우
            // Transition Controller
            let vc = NewPasswordVC()
            vc.viewModel.username = self.viewModel.name
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
        
    // MARK: - Helpers
    
    func configureUI() {
        // 크기 비율
        let tfWidth = Constant.width * 0.73
        let tfHeight = Constant.height * 0.06
        
        // leftView - 추후에 각각의 텍스트 필드에 맞는 이미지로 변경할 것.
        let nameleftView = addLeftView(image: #imageLiteral(resourceName: "nameOn"))
        let idleftView = addLeftView(image: #imageLiteral(resourceName: "idOn"))
        let phoneleftView = addLeftView(image: #imageLiteral(resourceName: "emailOn"))
        let certificationleftView = addLeftView(image: #imageLiteral(resourceName: "authOn"))

        // 오토레이아웃 적용
        view.addSubview(nameTextField)
        setupTextField(nameTextField, placehoder: "이름", leftView: nameleftView)
        nameTextField.setDimensions(height: tfHeight, width: tfWidth)
        nameTextField.centerX(inView: view)
        nameTextField.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                             paddingTop: 20)
        
        view.addSubview(idTextField)
        setupTextField(idTextField, placehoder: "아이디", leftView: idleftView)
        idTextField.setDimensions(height: tfHeight, width: tfWidth)
        idTextField.centerX(inView: view)
        idTextField.anchor(top: nameTextField.bottomAnchor,
                           paddingTop: 20)
        
        
        view.addSubview(emailTextField)
        setupTextField(emailTextField, placehoder: "이메일", leftView: phoneleftView)
        emailTextField.setDimensions(height: tfHeight, width: tfWidth)
        emailTextField.centerX(inView: view)
        emailTextField.anchor(top: idTextField.bottomAnchor,
                              paddingTop: 20)
        
        // "인증번호 발송" 버튼 (UIButton)
        sendingNumButton.addTarget(self, action: #selector(onTimerStart), for: .touchUpInside)
        view.addSubview(sendingNumButton)
        sendingNumButton.setDimensions(height: 25, width: 80)
        sendingNumButton.anchor(bottom: emailTextField.bottomAnchor,
                                right: emailTextField.rightAnchor,
                                paddingBottom: 10)
        
        view.addSubview(certificationTextField)
        setupTextField(certificationTextField, placehoder: "인증번호", leftView: certificationleftView)
        certificationTextField.setDimensions(height: tfHeight, width: tfWidth)
        certificationTextField.centerX(inView: view)
        certificationTextField.anchor(top: emailTextField.bottomAnchor,
                                      paddingTop: 20)
        
        // "03:00" UILabel (인증번호 TextField의 rightView)
        let timerView = UIView(frame: CGRect(x: 0, y: 0, width: 31, height: 13))
        timerLabel.frame = CGRect(x: 0, y: 10, width: 31, height: 13)
        timerView.addSubview(timerLabel)
        certificationTextField.rightView = timerView
        certificationTextField.rightViewMode = .always
        
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




// MARK: - UITextField

private extension FindingPwdByEmailVC {
    // 텍스트필드 콜벡메소드
    @objc func textDidChange(sender: UITextField) {
        guard let text = sender.text else { return }
        // 텍스트필드에 값을 입력할 때마다, ViewModel에 값을 Input
        switch sender {
        case nameTextField:
            viewModel.name = text
        case idTextField:
            print("DEBUG: idTextField is \(text)")
            viewModel.typingID = text
        case emailTextField:
            viewModel.email = text
        case certificationTextField:
            viewModel.certificationNumber = Int(text) ?? 0
            // 입력값이 nil 일 때, .gray 입력값이 있다면, .mainOrange
            completeButton.backgroundColor = textFieldNullCheck(sender) ? .mainOrange : .gray
        default:
            print("DEBUG: default in switch Statement...")
        }
    }
    
    // 텍스트필드에 콜벡메소드 추가
    func configureNotificationObservers() {
        nameTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        idTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        emailTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        certificationTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
    }
    
    
}


// MARK: - Timer

private extension FindingPwdByEmailVC {
    /* 타이머 시작버튼 클릭 */
    @objc func onTimerStart(_ sender: Any) {
        // "인증번호 발송" 을 클릭한 경우, "아이디찾기"API가 호출되어 아이디가 일치하는 아이디인지 확인한다. 타이머 실행은 "MARK: - API 에서 담당하고 있다."
        FindingPwdByEmailDataManager().findingIDResultByEmail(FindingPwdByEmailInput(receiver: "\(viewModel.email)", name: "\(viewModel.name)"), viewController: self)
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

extension FindingPwdByEmailVC {
    func didSucceedSendingID(response: FindingPwdByEmailResponse) {
        guard let id = response.sUsername else { return }
        viewModel.receivedID = id
        
        /* 이곳에 타이머를 생성한 이유 : API 데이터 수신 시간과, viewModel.idIsValid 시간을 serial로 하기 위함.*/
        // 1. 아이디 찾기 API 를 호출하여 작성된 아이디와 일치하는지 여부를 확인한다.
        // 2-1. 만약 일치하면, 타이머 시작 + 인증번호 API를 호출한다.
        // 2-2. 만약 불일치하면, 일치하지 않은 메시지를 띄워준다. 그리고 아무것도 호출하지 않는다.
        if viewModel.idIsValid {
            if let timer = vTimer {
                if !timer.isValid {
                    vTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerCallback), userInfo: nil, repeats: true)
                } else {
                    timer.invalidate()
                    self.totalTime = 180
                    vTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerCallback), userInfo: nil, repeats: true)
                }
            }else{
                vTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerCallback), userInfo: nil, repeats: true)
            }
            // 타이머 호출과 동시에 인증번호를 발송한다.
            FindingPwdByEmailDataManager().certificationNumberByEmail(ByEmailInput(receiver: "\(viewModel.email)", name: "\(viewModel.name)"), viewController: self)
        } else {
            // 불일치한 경우...
        }
    }
    
    func didSucceedReceiveNumber(response: String) {        // response 값에 서버 로그와 key:123456 이 함께 전달됨.
        let findIndex = response.firstIndex(of: "\"")!      // " 가 사용된 첫번째 텍스트 부터
        let lastIndex = response.lastIndex(of: "}")!        // } 가 사용된 마지막 텍스트 까지
        let responseData = response[findIndex..<lastIndex]  // 위 조건 텍스트를 저장
        
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
    }

}

// MARK: - Vaildation

private extension FindingPwdByEmailVC {
    
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
                    let rightView = self.settingLeftViewInTextField(tf, #imageLiteral(resourceName: "checkCorrect").withTintColor(.green))
                    tf.rightView = rightView
                    label.alpha = 0
                    tf.isVailedIndex = true
                }
            /* viewModel 로직에 불충족된 경우 */
            } else {
                UIView.animate(withDuration: 0.3) {
                    // TextField RightView 이미지
                    let rightView = self.settingLeftViewInTextField(tf, #imageLiteral(resourceName: "checkError").withTintColor(.red))
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

private extension FindingPwdByEmailVC {
    
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
