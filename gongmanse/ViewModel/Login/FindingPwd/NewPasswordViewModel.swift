//
//  NewPasswordViewModel.swift
//  gongmanse
//
//  Created by 김우성 on 2021/04/01.
//

import Foundation
import UIKit.UIColor

struct NewPasswordViewModel: AuthenticationViewModel {
    
    var username: String = "" // ID
    var password: String
    var rePassword: String
    
    init(password: String = "", rePassword: String = " ") {
        self.password = password
        self.rePassword = rePassword
    }
    
    
    var formIsValid: Bool {
        return password == rePassword
    }
    
    var buttonBackgroundColor: UIColor {
        return formIsValid ? .mainOrange : .progressBackgroundColor
    }
    
    var buttonTitleColor: UIColor {
        return .white
    }
    
    // 정규표현식 적용 -> Extension > String 에 작성
    var passwordIsValid: Bool {
        return password.validatePassword()
    }
    
    // 비밀번호 재입력 로직
    var confirmPasswrdIsVaild: Bool {
        return password == rePassword ? true : false
    }
}
