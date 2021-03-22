//
//  RegistrationResponse.swift
//  gongmanse
//
//  Created by 김우성 on 2021/03/22.
//
//  https://api.gongmanse.com/v1/members (response)

import Foundation


struct RegistrationResponse: Decodable {
    // response
    var code: Int
    var message: String
    var errors: Error?
}

struct Error: Decodable {
    var username: String?
    var confirmPassword: String?
    var nickname: String?
    var phoneNumber: String?
    var verificationCode: String?
}
