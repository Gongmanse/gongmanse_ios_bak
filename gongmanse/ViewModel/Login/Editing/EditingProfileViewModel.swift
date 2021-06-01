//
//  EditingProfileViewModel.swift
//  gongmanse
//
//  Created by 김우성 on 2021/06/01.
//

import UIKit
import Foundation

struct EditingProfileViewModel {
    
    var password: String = "DEFAULT"
    var confirmPassword: String = "DEFAULT"
    var username: String = "DEFAULT"
    var nickname: String = "DEFAULT"
    var email: String = "DEFAULT"
    
    var formIsValid: Bool {
        return password == confirmPassword
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
        return password == confirmPassword ? true : false
    }
}
