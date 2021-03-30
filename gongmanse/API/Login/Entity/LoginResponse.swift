//
//  LoginResponse.swift
//  gongmanse
//
//  Created by 김우성 on 2021/03/29.
//  https://api.gongmanse.com/v1/auth/token

import Foundation

/* 로그인 */
struct LoginResponse: Decodable {
    // response
    var token: String?          // API) 로그인 성공하면 token & refresh_token 만 출력
    var refresh_token: String?  // API) 로그인 성공하면 token & refresh_token 만 출력
    var message: String?        // API) 로그인에 실패하면 메세지만 출력.
}
