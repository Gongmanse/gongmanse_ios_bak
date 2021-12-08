//
//  CheckMember.swift
//  gongmanse
//
//  Created by 조철희 on 2021/12/08.
//

struct CheckMember: Decodable {
    var data: String
}

struct AuthNumResponse: Decodable {
    var key: Int?            // API) 로그인 성공하면, key 만 출력.
    var message: String?        // API) 로그인 실패하면, message 만 출력.
    var errors: ErrorResponse?
}

struct ErrorResponse: Decodable {
    var receiver_type: String?
    var receiver: String?
    var name: String?
}
