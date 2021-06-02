//
//  UpdateProfileImageInput.swift
//  gongmanse
//
//  Created by 김우성 on 2021/06/02.
//

import Foundation
import UIKit

struct UpdateProfileImageInput: Encodable {
    
    var file: Data
    var token: String
}
