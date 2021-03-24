//
//  CertificationNumberResponse.swift
//  gongmanse
//
//  Created by 김우성 on 2021/03/23.
//

import Foundation
/* 인증번호 */
struct CertificationNumberResponses: Decodable {
    // response
    var message: String
    var data: idData?
}

struct idData: Decodable {
    var id: Int
}


/* 아이디 중복여부 확인 */
struct idDuplicateCheckResponse: Decodable {
    var data: String
}
