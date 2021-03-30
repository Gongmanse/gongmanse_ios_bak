//
//  RegistrationVCViewModel.swift
//  gongmanse
//
//  Created by 김우성 on 2021/03/29.
//

import Foundation

class RegistrationVCViewModel {
    
    var firstAgree = false
    var secondAgree = false
    
    var agreeIsValid: Bool {
        return firstAgree == true && secondAgree == true
    }
    
    
    
}
