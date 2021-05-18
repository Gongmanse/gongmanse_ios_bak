//
//  LoginGetProfile.swift
//  gongmanse
//
//  Created by wallter on 2021/05/18.
//

import Foundation


// 프로필 정보조회, 포스트맨 01010 - 프로필 정보 조회
struct LoginGetProfile: Codable {
    let sNickname: String?
    let sFirstName: String?
    let sImage: String?
    let sEmail: String?
    let eType: String?
    let sUsername: String?
//    let dtPremiumActivate: String?
//    let dtPremiumExpire: String?
}
