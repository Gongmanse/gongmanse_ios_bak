//
//  FindingPwdViewModel.swift
//  gongmanse
//
//  Created by 김우성 on 2021/03/31.
//

import Foundation
import UIKit.UIColor

class FindingPwdViewModel: AuthenticationViewModel {
    
    var typingID: String?
    var receivedID: String?          // 인증번호 발송 시, 전달받을 아이디. 이를 통해 아이디를 정확한 값을 넣었는지 확인.
    var name: String
    var cellPhone: String
    var email: String
    var certificationNumber: Int
    var receivedKey: Int?
    
    init(name: String = "", cellPhone: String = "",email: String = "" ,number: Int = 0) {
        self.name = name
        self.cellPhone = cellPhone
        self.certificationNumber = number
        self.email = email
    }
    
    // 아이디 일치여부 확인
    var idIsValid: Bool {
        guard let typingID = self.typingID else { return false }
        guard let receivedID = self.receivedID else { return false }
        return typingID == receivedID
    }
    
    // 인증번호 일치여부 확인
    var formIsValid: Bool {
        guard let key = self.receivedKey else { return false }
        return certificationNumber == key
    }
    
    var buttonBackgroundColor: UIColor = UIColor.gray
    
    var buttonTitleColor: UIColor = UIColor.gray
}
    
