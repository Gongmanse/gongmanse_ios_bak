//
//  SearchConsultationModel.swift
//  gongmanse
//
//  Created by wallter on 2021/05/06.
//

import Foundation

struct SearchConsultationModel: Codable {
    
    let totalNum: String?
    var data: [SearchDataModel]
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
    
    var simpleDt: String {
        let dateGet = DateFormatter()
        dateGet.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let beforeDate = dateGet.date(from: dtRegister ?? "")
        if beforeDate == nil {
            return ""
        }
        let elapsed: Int64 = Int64(Date().timeIntervalSince(beforeDate!))
        if elapsed < 60 {
            return "\(elapsed)초 전"
        } else if elapsed < 60 * 60 {
            return "\(elapsed / 60)분 전"
        } else if elapsed < 60 * 60 * 24 {
            return "\(elapsed / 3600)시간 전"
        } else if elapsed < 60 * 60 * 24 * 7 {
            return "\(elapsed / 86400)일 전"
        } else if elapsed < 60 * 60 * 24 * 7 * 4 {
            return "\(elapsed / 604800)주 전"
        } else if elapsed < 60 * 60 * 24 * 7 * 4 * 12 {
            return "\(elapsed / 2419200)개월 전"
        } else {
            return "\(elapsed / 29030400)년 전"
        }
    }
}

// 응답보낼 메소드
struct SearchConsultationPostModel: Codable {
    
    let keyword: String?
    let sortID: String?
    let offset: String?
    
    enum CodingKeys: String, CodingKey {
        case keyword
        case sortID = "sort_id"
        case offset
    }
}




