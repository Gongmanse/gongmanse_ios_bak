//
//  ByPhoneResponse.swift
//  gongmanse
//
//  Created by 김우성 on 2021/03/29.
//  raw - JSON 으로 구성됨

import Foundation

struct ByPhoneResponse: Decodable {
    var key: Int?            // API) 로그인 성공하면, key 만 출력.
    var message: String?        // API) 로그인 실패하면, message 만 출력.
    var errors: Errors?
}

struct Errors: Decodable {
    var receiver_type: String?
    var receiver: String?
    var name: String?
}
