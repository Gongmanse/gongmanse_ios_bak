//
//  CertificationNumberInput.swift
//  gongmanse
//
//  Created by 김우성 on 2021/03/23.
//
//  https://api.gongmanse.com/v1/sms/verifications

import Foundation
/* 인증번호 */
struct CertificationNumberInput: Encodable {
    var phone_number: Int
}

/* 아이디 중복여부 확인 */
struct idDuplicateCheckInput: Encodable {
    var username: String
}
