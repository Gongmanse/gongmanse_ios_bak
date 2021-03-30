//
//  ByPhoneInput.swift
//  gongmanse
//
//  Created by 김우성 on 2021/03/29.
//  raw - JSON 으로 구성됨

import Foundation

struct ByPhoneInput: Encodable {
    var receiver_type: String = "cellphone" // eamil OR cellphone
    var receiver: String                    // 01047850519
    var name: String                        // 김우성
}
