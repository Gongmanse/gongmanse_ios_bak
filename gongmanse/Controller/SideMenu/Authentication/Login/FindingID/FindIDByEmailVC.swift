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
    
    // MARK: IBOutlet
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var CertificationNumberTextField: UITextField!

    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        
    }

    // MARK: - Actions
    
    @objc func handleDismiss() {
        
    }
    
    
    // MARK: - Helpers
    
    func configureUI() {
        /* UITextField Properties and LeftView */
        
        let tfWidth = view.frame.width - 107
        
        // 이름 TextField leftView
        let nameImage = #imageLiteral(resourceName: "myActivity")
        let nameleftView = UIView(frame: CGRect(x: 0, y: 10, width: 20, height: 20))
        let nameImageView = UIImageView(frame: CGRect(x: 0, y: 10, width: 20, height: 20))
        nameImageView.image = nameImage
        nameleftView.addSubview(nameImageView)
        
        // 이메일 TextField leftView
        let emailImage = #imageLiteral(resourceName: "myActivity")
        let emailLeftView = UIView(frame: CGRect(x: 0, y: 10, width: 20, height: 20))
        let emailImageView = UIImageView(frame: CGRect(x: 0, y: 10, width: 20, height: 20))
        emailImageView.image = emailImage
        emailLeftView.addSubview(emailImageView)
        
        // 인증번호 TextField leftView
        let certificationImage = #imageLiteral(resourceName: "myActivity")
        let certificationleftView = UIView(frame: CGRect(x: 0, y: 10, width: 20, height: 20))
        let certificationimageView = UIImageView(frame: CGRect(x: 0, y: 10, width: 20, height: 20))
        certificationimageView.image = certificationImage
        certificationleftView.addSubview(certificationimageView)
        
        /* UITextField setting */
        // 이름 TextField
        nameTextField.setDimensions(height: 50, width: tfWidth - 20)
        setupTextField(nameTextField, placehoder: "이름", leftView: nameleftView)
        nameTextField.centerX(inView: view)
        nameTextField.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                             paddingTop: 20)
        
        // 이메일 TextField
        emailTextField.setDimensions(height: 50, width: tfWidth - 20)
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
        CertificationNumberTextField.setDimensions(height: 50, width: tfWidth - 20)
        setupTextField(CertificationNumberTextField, placehoder: "인증번호", leftView: certificationleftView)
        CertificationNumberTextField.keyboardType = .numberPad
        CertificationNumberTextField.centerX(inView: view)
        CertificationNumberTextField.anchor(top: emailTextField.bottomAnchor,
                             paddingTop: 20)
        
        // "03:00" UILabel (인증번호 TextField의 rightView)
        let timerView = UIView(frame: CGRect(x: 0, y: 0, width: 31, height: 13))
        
        

        
        timerLabel.frame = CGRect(x: 0, y: 10, width: 31, height: 13)
        timerView.addSubview(timerLabel)

        CertificationNumberTextField.rightView = timerView
        CertificationNumberTextField.rightViewMode = .always
        
        
        
    }
}


// MARK: - Timer

private extension FindIDByEmailVC {
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
