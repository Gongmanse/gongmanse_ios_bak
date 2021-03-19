//
//  LoginVC.swift
//  gongmanse
//
//  Created by 김우성 on 2021/03/19.
//

import UIKit

class LoginVC: UIViewController {

    
    // MARK: - IBOutlet
    
    @IBOutlet weak var idTextField: UITextField!
    
    lazy var dividerView: UIView = {
        let view = UIView()
        view.backgroundColor = .mainOrange
        return view
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }

    
    func configureUI() {
        let tfWidth = view.frame.width - 40
        // 아이디 Textfield
        idTextField.setDimensions(height: 50, width: tfWidth - 20)
        custonTextField(tf: idTextField, width: tfWidth, leftImage: #imageLiteral(resourceName: "settings"), placehoder: "아이디")
        idTextField.keyboardType = .emailAddress
        idTextField.centerY(inView: view)
        idTextField.centerX(inView: view)
        
        

                                
        
    }
    



}
