//
//  RatingInput.swift
//  gongmanse
//
//  Created by 김우성 on 2021/05/31.
//

import Foundation

struct RatingInput: Encodable {
    
    var token: String
    var video_id: Int
    var rating: Int
}
