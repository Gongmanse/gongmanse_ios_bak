//
//  SearchConsultationModel.swift
//  gongmanse
//
//  Created by wallter on 2021/05/06.
//

import Foundation

struct SearchConsultationModel: Codable {
    
    let totalNum: String?
    let data: [SearchDataModel]
}

struct SearchDataModel: Codable {
    
    let iAuthor: String?
    let iViews: String?
    let consultationID: String?
    let dtAnswerRegister: String?
    let sQuestion: String?
    let sNickname: String?
    let sProfile: String?
    let sAnswer: String?
    let iAnswer: String?
    let dtRegister: String?
    let sFilepaths: String?
    
    enum CodingKeys: String, CodingKey {
        case iAuthor, iViews, dtAnswerRegister, sQuestion, sNickname, sProfile, sAnswer, iAnswer, dtRegister, sFilepaths
        case consultationID = "consultation_id"
    }
}

// 응답보낼 메소드
struct SearchPostModel: Codable {
    
    let keyword: String
    let sortID: String
    
    enum CodingKeys: String, CodingKey {
        case keyword
        case sortID = "sort_id"
    }
}




