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

class RegistrationUserInfoViewModel: AuthenticationViewModel {
    var username: String?                // username - API와 동일한 명, username이지만 ID
    var password: String?                // 영문 대소문자 + 숫자 + 특수문자 8 ~ 12자
    var confirm_password: String?        // 영문 대소문자 + 숫자 + 특수문자 8 ~ 12자
    var first_name: String?              // 한글 이름
    var nickname: String?                // 글자수 제한
    var phone_number: String?            // "01047850519" String으로 넘겨주면 API에서 Int로 인식함.
    var verification_code: Int?          // (자신의 폰으로 받아야하는 숫자) 431212(6자리) - 일정시간 지나면 다시 발급받아야함.
    var email: String?                   // woosung@test.com
    var address1: String?                // 45 gasnaro(비필수항목)
    var address2: String?                // #45(비필수항목)
    var city: String?                    // jeju(비필수항목)
    var country: String?                 // Korea(비필수항목)
    
    var tf: SloyTextField?               // leftViewColor 설정을 위한 객체생성
    var idIsValid: Bool = false
    var nicknameIsValid: Bool = false
    
    // 정규표현식 적용 -> Extension > String 에 작성
    var passwordIsValid: Bool {
        guard let pwd = password else { return false }
        return pwd.validatePassword()
    }
    
    // 비밀번호 재입력 로직
    var confirmPasswrdIsVaild: Bool {
        guard let pwd = password else { return false }
        guard let cofirmPwd = confirm_password else { return false }
        return pwd == cofirmPwd ? true : false
    }
    
    // 이름 로직
    var nameIslVaild: Bool {
        guard let name = first_name else { return false }
        return name.validatName()
    }
    
    // 이메일 로직
    var emailIsValid: Bool {
        guard let email = email else { return false }
        return email.validateEmail()
    }
    
    // 휴대전화번호 로직
    var phoneNumberIsValid: Bool {
        guard let phoneNumber = phone_number else { return  false }
        return phoneNumber.validatePhoneNumber()
    }
    
    // 인증번호 로직
    var verificationNumberIsValid: Bool {
        guard let number = verification_code else { return false }
        return number > 99999 && number < 1000000 ? true : false
    }
    
    // 항목이 유효성검사를 충족하는지 로직
    var formIsValid: Bool {
        return idIsValid == true
            && passwordIsValid == true
            && confirmPasswrdIsVaild == true && nameIslVaild == true
            && nicknameIsValid == true && emailIsValid == true
    }
    
    // 양식을 모두 채운 경우, 버튼의 색상을 결정하는 로직
    var buttonBackgroundColor: UIColor {
        return formIsValid ? .mainOrange : .progressBackgroundColor
    }
    
    // 양식을 모두 채운경우, 버튼의 텍스트 색상을 결정하는 로직
    var buttonTitleColor: UIColor {
        return formIsValid ? .white : UIColor(white: 1, alpha: 0.67)
    }
    
    // leftViewColor 결정 로직
    var leftViewColor: UIColor {
        guard let textField = tf else { return .mainOrange}
        return textField.isFirstResponder ? .mainOrange : (textField.isVailedIndex ? .gray : .red)
    }
    

    
}
