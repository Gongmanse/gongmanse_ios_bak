//
//  RegistrationUserInfoViewModel.swift
//  gongmanse
//
//  Created by 김우성 on 2021/03/24.
//

import UIKit

protocol FormViewModel {
    func updateForm()
}

protocol AuthenticationViewModel {
    var formIsValid: Bool { get }
    var buttonBackgroundColor: UIColor { get }
    var buttonTitleColor: UIColor { get }
}


struct RegistrationUserInfoViewModel: AuthenticationViewModel {
    var username: String?                // woosung
    var password: String?                // 12341234
    var confirm_password: String?        // 12341234
    var first_name: String?              // woosung
    var nickname: String?                // woosung
    var phone_number: Int?               // 01047850519
    var verification_code: Int?          // (자신의 폰으로 받아야하는 숫자) 431212 - 일정시간 지나면 다시 발급받아야함.
    var email: String?                   // woosung@test.com
    var address1: String?                // 45 gasnaro
    var address2: String?                // #45
    var city: String?                    // jeju
    var country: String?                 // Korea
    
    // 정규표현식
    var passwordIsValid: Bool {
        return password!.validatePassword()
    }

    
    // 항목이 비어있는지 확인하는 로직
    var formIsValid: Bool {
        return username?.isEmpty == false
//            && password?.isEmpty == false
//            && confirm_password?.isEmpty == false && first_name?.isEmpty == false
//            && nickname?.isEmpty == false && email?.isEmpty == false
//            && address1?.isEmpty == false && address2?.isEmpty == false
//            && city?.isEmpty == false && country?.isEmpty == false
    }
    
    // 양식을 모두 채운 경우, 버튼의 색상을 결정하는 로직
    var buttonBackgroundColor: UIColor {
        return formIsValid ? .mainOrange : .progressBackgroundColor
    }
    
    // 양식을 모두 채운경우, 버튼의 텍스트 색상을 결정하는 로직
    var buttonTitleColor: UIColor {
        return formIsValid ? .white : UIColor(white: 1, alpha: 0.67)
    }
    
}
