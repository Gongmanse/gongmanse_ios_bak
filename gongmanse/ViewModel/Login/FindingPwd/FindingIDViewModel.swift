//
//  FindingPwdViewModel.swift
//  gongmanse
//
//  Created by 김우성 on 2021/03/31.
//

import Foundation
import UIKit.UIColor

class FindingIDViewModel: AuthenticationViewModel {
    
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
    
    var formIsValid: Bool {
        guard let key = self.receivedKey else { return false }
        return certificationNumber == key
    }
    
    var buttonBackgroundColor: UIColor = UIColor.gray
    
    var buttonTitleColor: UIColor = UIColor.gray
}
    
