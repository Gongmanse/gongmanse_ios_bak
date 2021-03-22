//
//  CheckUserIdentificationVC.swift
//  gongmanse
//
//  Created by 김우성 on 2021/03/22.
//

import UIKit
import Alamofire

class CheckUserIdentificationVC: UIViewController {

    // dummy Data
    // TextField에서 데이터를 받아서
//    var input = RegistrationInput(username: "유저네임했음",
//                                  password: "12341235",
//                                  confirmPassword: "12341234",
//                                  firstname: "woosung",
//                                  nickname: "woosung",
//                                  phoneNumber: 01047850519,
//                                  verificationCode: 123123,
//                                  email: "kipsong133@gmail.com",
//                                  address1: "asdf",
//                                  address2: "asdf",
//                                  city: "asdf",
//                                  zip: 123,
//                                  country: "asdf")
    
    var userInfoData = RegistrationInput(username: "woosungs", password: "", confirm_password: "", first_name: "", nickname: "", phone_number: 0, verification_code: 0, email: "", address1: "", address2: "", city: "", zip: 0, country: "")
    
    var userInfoData2 = RegistrationInput(username: "woosungs", password: "woosungs", confirm_password: "woosungs", first_name: "woosungs", nickname: "woosccungs", phone_number: 0, verification_code: 0, email: "woosungs@text.com", address1: "woosungs", address2: "woosungs", city: "woosungs", zip: 0, country: "woosungs")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cofigureNavi()
        print("DEBUG: nextPageData: \(userInfoData2)")
    }


    func cofigureNavi() {
        // 내비게이션 타이틀 폰트 변경
        let title = UILabel()
        title.text = "회원가입"
        title.font = UIFont.appBoldFontWith(size: 17)
        navigationItem.titleView = title
        DispatchQueue.global().async {
            RegistrationDataManager().signUp(self.userInfoData2, viewController: self)
        }
        
    }

}


// MARK: - 회원가입API

extension CheckUserIdentificationVC {
    func didSuccessRegistration(message: String) {
        // TODO: 회원가입 성공 시, 진행할 로직 작성할 것.
        print("DEBUG: 회원가입이 성공했습니다.")
    }
    
    func failedToRequest(message: String) {
        print("DEBUG: 회원가입이 실패했습니다.")
    }
}
