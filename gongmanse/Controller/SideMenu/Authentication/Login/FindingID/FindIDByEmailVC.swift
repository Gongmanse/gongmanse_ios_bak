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
    @IBOutlet weak var SendingCertificationNumber: UIButton!
    @IBOutlet weak var timerLabel: UILabel!
    
    
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
        let tfWidth = view.frame.width - 40
        
        // 이름 TextField
        custonTextField(tf: nameTextField,
                        width: tfWidth,
                        leftImage: #imageLiteral(resourceName: "settings"), placehoder: "이름")
        nameTextField.setDimensions(height: 30, width: tfWidth - 20)
        nameTextField.centerX(inView: view)
        nameTextField.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                             paddingTop: 20)
        
        


    }
}
