//
//  FindIDByPhoneVC.swift
//  gongmanse
//
//  Created by 김우성 on 2021/03/19.
//
// 아이디찾기 > 휴대전화로 찾기

import UIKit

class FindIDByPhoneVC: UIViewController {
    
    // MARK: - Properties
    
    var viewModel = FindingIDByPhoneViewModel()
    
    var pageIndex: Int! // 상단탭바 구현을 위한 프로퍼티
    var vTimer: Timer?          // 인증번호 타이머
    var totalTime: Int = 180    // 인증번호 시작 03:00
    
    private let nameTextField = SloyTextField()
    private let phoneTextField = SloyTextField()
    private let certificationTextField = SloyTextField()
    
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
    }
    
    // MARK: - Helpers
    
    func configureUI() {
        // 기본값
        let tfHeight = CGFloat(50)
        let tfWidth = view.frame.width - 107
        
        // leftView - 추후에 각각의 텍스트 필드에 맞는 이미지로 변경할 것.
        let nameleftView = addLeftView(image: #imageLiteral(resourceName: "myActivity"))
        let phoneleftView = addLeftView(image: #imageLiteral(resourceName: "myActivity"))
        let certificationleftView = addLeftView(image: #imageLiteral(resourceName: "myActivity"))

        // 오토레이아웃 적용
        view.addSubview(nameTextField)
        setupTextField(nameTextField, placehoder: "이름", leftView: nameleftView)
        nameTextField.setDimensions(height: tfHeight, width: tfWidth)
        nameTextField.centerX(inView: view)
        nameTextField.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                             paddingTop: 20)
        
        view.addSubview(phoneTextField)
        setupTextField(phoneTextField, placehoder: "휴대전화 번호", leftView: phoneleftView)
        phoneTextField.setDimensions(height: tfHeight, width: tfWidth)
        phoneTextField.centerX(inView: view)
        phoneTextField.anchor(top: nameTextField.bottomAnchor,
                              paddingTop: 20)
        
        view.addSubview(certificationTextField)
        setupTextField(certificationTextField, placehoder: "인증번호", leftView: certificationleftView)
        certificationTextField.setDimensions(height: tfHeight, width: tfWidth)
        certificationTextField.centerX(inView: view)
        certificationTextField.anchor(top: phoneTextField.bottomAnchor,
                                      paddingTop: 20)
        
        // "인증번호 발송" 버튼 (UIButton)
        sendingNumButton.addTarget(self, action: #selector(onTimerStart), for: .touchUpInside)
        view.addSubview(sendingNumButton)
        sendingNumButton.setDimensions(height: 25, width: 80)
        sendingNumButton.anchor(bottom: phoneTextField.bottomAnchor,
                                right: phoneTextField.rightAnchor,
                                paddingBottom: 10)
        
        // "03:00" UILabel (인증번호 TextField의 rightView)
        let timerView = UIView(frame: CGRect(x: 0, y: 0, width: 31, height: 13))
        timerLabel.frame = CGRect(x: 0, y: 10, width: 31, height: 13)
        timerView.addSubview(timerLabel)
        certificationTextField.rightView = timerView
        certificationTextField.rightViewMode = .always
        }
    
    
    // 텍스트필드 콜벡메소드
    @objc func textDidChange(sender: UITextField) {
        guard let text = sender.text else { return }
        
        switch sender {
        case nameTextField:
            viewModel.name = text
        case phoneTextField:
            viewModel.cellPhone = text
        case certificationTextField:
            viewModel.certificationNumber = Int(text) ?? 0
        default:
            print("DEBUG: default in switch Statement...")
        }
    }
    
    // 텍스트필드에 콜벡메소드 추가
    func configureNotificationObservers() {
        nameTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        phoneTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        certificationTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
    }
    
}


// MARK: - Timer

private extension FindIDByPhoneVC {
    /** 타이머 시작버튼 클릭 */
    @objc func onTimerStart(_ sender: Any) {
        if let timer = vTimer {
            //timer 객체가 nil 이 아닌경우에는 invalid 상태에만 시작한다.
            if !timer.isValid {
                /** 1초마다 timerCallback함수를 호출하는 타이머 */
                vTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerCallback), userInfo: nil, repeats: true)
            } else {    // 타이머 실행중에 다시 타이머를 실행했다면, 기존의 타이머를 멈추고 난 후, 실행한다.
                timer.invalidate()
                self.totalTime = 180
                vTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerCallback), userInfo: nil, repeats: true)
            }
        }else{
            //timer 객체가 nil 인 경우에 객체를 생성하고 타이머를 시작한다.
            /** 1초마다 timerCallback함수를 호출하는 타이머 */
            vTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerCallback), userInfo: nil, repeats: true)
        }
        
        // 인증번호 발송 - 이곳에 구현할 것.
        // 인증번호 발송을 클릭했을 때, DataManager method를 호출한다.
        
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

