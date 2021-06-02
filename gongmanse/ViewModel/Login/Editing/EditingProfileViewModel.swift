//
//  EditingProfileViewModel.swift
//  gongmanse
//
//  Created by 김우성 on 2021/06/01.
//

import UIKit
import Foundation

struct EditingProfileViewModel {
    
    var password: String = ""
    var confirmPassword: String = ""
    var username: String = ""
    var nickname: String = ""
    var email: String = ""
    
    
    
    var buttonBackgroundColor: UIColor {
        return passwordIsValid && confirmPasswrdIsVaild && emailIsValid && nicknameIsValid ? .mainOrange : .gray
    }
    
    var buttonTitleColor: UIColor {
        return .white
    }
    
    // 비밀번호 양식 준수 여부 Validation (Extension > String 에 코드 참조)
    var passwordIsValid: Bool {
        return password.validatePassword()
    }
    
    // 비밀번호 재입력 로직
    var confirmPasswrdIsVaild: Bool {
        return password == confirmPassword ? true : false
    }
    
    var emailIsValid: Bool {
        return email.validateEmail()
    }
    
    // 닉네임 양식은 자유
    var nicknameIsValid: Bool {
        return !nickname.isEmpty
    }
}
