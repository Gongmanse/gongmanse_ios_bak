//
//  FindingPwdByEmailInput.swift
//  gongmanse
//
//  Created by 김우성 on 2021/04/01.
//

import Foundation

struct FindingPwdByEmailInput: Encodable {
    var receiver_type: String = "email" // eamil OR cellphone
    var receiver: String                // woosung@gmail.com
    var name: String                    // 김우성
}
