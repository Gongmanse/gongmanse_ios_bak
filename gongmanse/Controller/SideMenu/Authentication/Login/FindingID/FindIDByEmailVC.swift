//
//  FindIDByEmailVC.swift
//  gongmanse
//
//  Created by 김우성 on 2021/03/19.
//




import UIKit

class FindIDByEmailVC: UIViewController {

    // MARK: - Properties
    
    var upperLabel: UILabel!
    var pageIndex: Int!

    // MARK: - IBOutlet
    
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
    
    
    // MARK: - Helper functions
    
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
        let emailImage = #imageLiteral(resourceName: "home_on")
        let emailLeftView = UIView(frame: CGRect(x: 0, y: 10, width: 20, height: 20))
        let emailImageView = UIImageView(frame: CGRect(x: 0, y: 10, width: 20, height: 20))
        emailImageView.image = emailImage
        emailLeftView.addSubview(emailImageView)
        
        // 인증번호 TextField leftView
        let certificationImage = #imageLiteral(resourceName: "home_on")
        let certificationleftView = UIView(frame: CGRect(x: 0, y: 10, width: 20, height: 20))
        let certificationimageView = UIImageView(frame: CGRect(x: 0, y: 10, width: 20, height: 20))
        certificationimageView.image = certificationImage
        certificationleftView.addSubview(certificationimageView)
        
        /* UITextField setting */
        // 이름 TextField
        nameTextField.setDimensions(height: 50, width: tfWidth - 20)
        nameTextField.placeholder = "이름"
        nameTextField.leftViewMode = .always
        nameTextField.leftView = nameleftView
        nameTextField.keyboardType = .emailAddress
        nameTextField.centerX(inView: view)
        nameTextField.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                             paddingTop: 20)
        
        // 이메일 TextField
        emailTextField.setDimensions(height: 50, width: tfWidth - 20)
        emailTextField.placeholder = "이메일"
        emailTextField.leftViewMode = .always
        emailTextField.leftView = emailLeftView
        emailTextField.keyboardType = .emailAddress
        emailTextField.centerX(inView: view)
        emailTextField.anchor(top: nameTextField.bottomAnchor,
                             paddingTop: 20)
        
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
        
        emailTextField.rightView = buttonView
        emailTextField.rightViewMode = .always
        
        // 인증번호 TextField
        CertificationNumberTextField.setDimensions(height: 50, width: tfWidth - 20)
        CertificationNumberTextField.placeholder = "인증번호"
        CertificationNumberTextField.leftViewMode = .always
        CertificationNumberTextField.leftView = certificationleftView
        CertificationNumberTextField.keyboardType = .numberPad
        CertificationNumberTextField.centerX(inView: view)
        CertificationNumberTextField.anchor(top: emailTextField.bottomAnchor,
                             paddingTop: 20)
        
        // "03:00" UILabel (인증번호 TextField의 rightView)
        let timerView = UIView(frame: CGRect(x: 0, y: 0, width: 31, height: 13))
        
        let timerLabel = UILabel()
        timerLabel.text = "03:00"
        timerLabel.font = UIFont.appRegularFontWith(size: 10)
        timerLabel.textColor = .black
        
        timerLabel.frame = CGRect(x: 0, y: 10, width: 31, height: 13)
        timerView.addSubview(timerLabel)

        CertificationNumberTextField.rightView = timerView
        CertificationNumberTextField.rightViewMode = .always
        
        
        
    }
}
