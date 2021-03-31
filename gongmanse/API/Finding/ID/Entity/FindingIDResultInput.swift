//
//  FindingIDResultInput.swift
//  gongmanse
//
//  Created by 김우성 on 2021/03/31.
//

import Foundation

struct FindingIDResultInput: Encodable {
    var receiver_type: String = "cellphone"
    var receiver: String
    var name: String
    
}
