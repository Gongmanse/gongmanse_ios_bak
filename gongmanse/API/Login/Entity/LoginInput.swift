//
//  LoginInput.swift
//  gongmanse
//
//  Created by 김우성 on 2021/03/29.
//  https://api.gongmanse.com/v1/auth/token
// 로그인
import Foundation

/* 로그인 */
struct LoginInput: Encodable {
    var grant_type = "password" // API에는 "refresh token"과 "password"가 있지만 "password"만 사용.
    var usr = ""
    var pwd = ""
}

