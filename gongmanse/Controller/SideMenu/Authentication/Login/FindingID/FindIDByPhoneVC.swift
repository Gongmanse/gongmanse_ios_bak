//
//  FindIDByPhoneVC.swift
//  gongmanse
//
//  Created by 김우성 on 2021/03/19.
//
// 아이디찾기 > 휴대전화로 찾기

import UIKit
import Alamofire

class FindIDByPhoneVC: UIViewController {
    
    // MARK: - Properties
    
    var viewModel = FindingViewModel()
    
    var pageIndex: Int! // 상단탭바 구현을 위한 프로퍼티
    var vTimer: Timer?          // 인증번호 타이머
    var totalTime: Int = 180    // 인증번호 시작 03:00
    
    private let nameTextField = SloyTextField()
    private let phoneTextField = SloyTextField()
    private let certificationTextField = SloyTextField()
    
    // "완료" 버튼
    private let completeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("완료", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .gray
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
        setupUI()
        configureNotificationObservers()
    }
    
    
    // MARK: - Actions
    
    // 완료 버튼 클릭 시, 호출되는 콜백메소드
    @objc func handleComplete() {
        
        if viewModel.formIsValid { // 인증번호가 사용자가 타이핑한 숫자와 일치하는 경우
            // Transition Controller
            let vc = FindIDResultVC()
            vc.viewModel = self.viewModel
            self.navigationController?.pushViewController(vc, animated: true)
            
        } else {
            presentAlert(message: "기입한 정보를 확인해주세요.", alignment: .center)
        }
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
            // 입력값이 nil 일 때, .gray 입력값이 있다면, .mainOrange
            completeButton.backgroundColor = textFieldNullCheck(sender) ? .mainOrange : .gray
            
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
    
    
    // MARK: - Helpers
    
    func configureUI() {
        // 기본값
        // 크기 비율
        let tfWidth = Constant.width * 0.73
        let tfHeight = Constant.height * 0.06
        
        // leftView - 추후에 각각의 텍스트 필드에 맞는 이미지로 변경할 것.
        let nameleftView = addLeftView(image: #imageLiteral(resourceName: "idOn"))
        let phoneleftView = addLeftView(image: #imageLiteral(resourceName: "phoneNumberOn"))
        let certificationleftView = addLeftView(image: #imageLiteral(resourceName: "authOn"))

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
        
        // "완료" UIButton
        view.addSubview(completeButton)
        completeButton.setDimensions(height: 40, width: tfWidth)
        completeButton.layer.cornerRadius = 10
        completeButton.centerX(inView: view)
        completeButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor,
                              paddingBottom: 20)
        completeButton.addTarget(self, action: #selector(handleComplete), for: .touchUpInside)
        }
    

}


// MARK: - Timer

private extension FindIDByPhoneVC {
    
    /** 타이머 시작버튼 클릭 */
    @objc func onTimerStart(_ sender: Any) {
        
        if viewModel.isNotNilTextField
            && viewModel.cellPhone.validatePhoneNumber() {
            
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
                    vTimer = Timer.scheduledTimer(timeInterval: 1,
                                                  target: self,
                                                  selector: #selector(timerCallback),
                                                  userInfo: nil,
                                                  repeats: true)
                }
            }else{
                //timer 객체가 nil 인 경우에 객체를 생성하고 타이머를 시작한다.
                /** 1초마다 timerCallback함수를 호출하는 타이머 */
                vTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerCallback), userInfo: nil, repeats: true)
            }
            
            let params: Parameters = [
                "name":"\(viewModel.name)",
                "phone":"\(viewModel.cellPhone)"
            ]
            FindingIDDataManager().findRegister(type: "cellphone", params, viewController: self)
        } else {
            presentAlert(message: "이름과 휴대전화를 확인해주세요.", alignment: .center)
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

/// 인증번호 API
extension FindIDByPhoneVC {
    func didSucceedCertificationNumber(response: AuthNumResponse) {
        
        self.sendingNumButton.setTitle("재발송", for: .normal)

        guard let key = response.key else {
            self.sendingNumButton.setTitle("인증번호 발송", for: .normal)
            vTimer?.invalidate()
            return presentAlert(message: "입력하신 정보를 확인해주세요.", alignment: .center)
        }
        viewModel.receivedKey = key
        print("DEBUG: key is \(key)...")
        
        if let message = response.message {
            presentAlert(message: message, alignment: .center)
            vTimer?.invalidate()
        }
    }
    // error response 즉시처리, 미사용함수
//    func didFaildCertificationNumber(response: AuthNumResponse) {
//        vTimer?.invalidate()
//        presentAlert(message: "\(String(describing: response.message))")
//    }
}

// MARK: - Vaildation

extension FindIDByPhoneVC {
    
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

private extension FindIDByPhoneVC {
    
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
