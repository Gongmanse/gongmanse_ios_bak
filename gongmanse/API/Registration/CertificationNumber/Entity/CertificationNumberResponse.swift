//
//  CertificationNumberResponse.swift
//  gongmanse
//
//  Created by 김우성 on 2021/03/23.
//

import Foundation

struct CertificationNumberResponses: Decodable {
    // response
    var message: String
    var data: idData?
}

struct idData: Decodable {
    var id: Int
}
