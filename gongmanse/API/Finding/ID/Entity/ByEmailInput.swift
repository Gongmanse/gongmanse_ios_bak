//
//  ByEmailInput.swift
//  gongmanse
//
//  Created by 김우성 on 2021/03/29.
//

import Foundation

struct ByEmailInput: Encodable {
    var receiver_type: String = "email" // eamil OR cellphone
    var receiver: String                // woosung@gmail.com
    var name: String                    // 김우성
}

