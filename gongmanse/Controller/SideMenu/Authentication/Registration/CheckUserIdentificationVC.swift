//
//  CheckUserIdentificationVC.swift
//  gongmanse
//
//  Created by 김우성 on 2021/03/22.
//

import UIKit

class CheckUserIdentificationVC: UIViewController {

    // dummy Data
    let input = RegistrationInput(username: "유저네임했음",
                                  password: "12341235",
                                  confirmPassword: "12341234",
                                  firstname: "woosung",
                                  nickname: "woosung",
                                  phoneNumber: 01047850519,
                                  verificationCode: 123123,
                                  email: "kipsong133@gmail.com",
                                  address1: "asdf",
                                  address2: "asdf",
                                  city: "asdf",
                                  zip: 123,
                                  country: "asdf")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cofigureNavi()
        
        
        
    }


    func cofigureNavi() {
        // 내비게이션 타이틀 폰트 변경
        let title = UILabel()
        title.text = "회원가입"
        title.font = UIFont.appBoldFontWith(size: 17)
        navigationItem.titleView = title
        RegistrationDataManager().signUp(input, viewController: self)
    }

}


// MARK: - 회원가입API post

extension CheckUserIdentificationVC {
    func didSuccessRegistration(message: String) {
        // TODO: 회원가입 성공 시, 진행할 로직 작성할 것.
    }
    
    func failedToRequest(message: String) {
        
    }
}
