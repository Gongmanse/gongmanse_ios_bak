//
//  CertificationNumberInput.swift
//  gongmanse
//
//  Created by 김우성 on 2021/03/23.
//
//  https://api.gongmanse.com/v1/sms/verifications

import Foundation

struct CertificationNumberInput: Encodable {
    var phone_number: Int
}
