//
//  FindingIDByPhoneViewModel.swift
//  gongmanse
//
//  Created by 김우성 on 2021/03/30.
//

import Foundation
import UIKit.UIColor

class FindingIDByPhoneViewModel: AuthenticationViewModel {
    
    var name: String
    var cellPhone: String
    var certificationNumber: Int
    var receivedKey: Int?
    
    init(name: String = "", cellPhone: String = "", number: Int = 0) {
        self.name = name
        self.cellPhone = cellPhone
        self.certificationNumber = number
    }
    
    var formIsValid: Bool {
        guard let key = self.receivedKey else { return false }
        return certificationNumber == key
    }
    
    var buttonBackgroundColor: UIColor = UIColor.gray
    
    var buttonTitleColor: UIColor = UIColor.gray
    
    
}
