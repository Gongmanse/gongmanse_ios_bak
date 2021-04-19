//
//  FindingPwdByPhoneResponse.swift
//  gongmanse
//
//  Created by 김우성 on 2021/04/01.
//

import Foundation

struct FindingPwdByPhoneResponse: Decodable {
    var sUsername: String?  // Input 값에 따른 일치하는 정보가 없는경우, response에서는 아무것도 호출하지 않음.
                            // 그러므로 Optional 선언.
}
