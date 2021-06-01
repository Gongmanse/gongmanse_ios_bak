//
//  EditingProfileResponse.swift
//  gongmanse
//
//  Created by 김우성 on 2021/06/01.
//

import Foundation

struct EditingProfileResponse: Decodable {
    
    
    let sNickname: String
    let sFirstName: String
    let sImage: String
    let sEmail: String
    let eType: String
    let sUsername: String
    let dtPremiumActivate: String
    let dtPremiumExpire: String
}
