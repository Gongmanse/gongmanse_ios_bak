//
//  RecentKeywordModel.swift
//  gongmanse
//
//  Created by wallter on 2021/05/11.
//

import Foundation

// 최근 검색어 목록 받아오는 모델
struct RecentKeywordModel: Codable {
    let data: [RecentKeywordDataModel]
}

struct RecentKeywordDataModel: Codable {
    let id: String?
    let sWords: String?
    let dtDateCreated: String?
    
    var convertDate: String {
        let date = DateFormatter()
        date.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let newdataPrint = DateFormatter()
        newdataPrint.dateFormat = "yyyy-MM-dd"
        
        let newdate = date.date(from: dtDateCreated ?? "")
        return newdataPrint.string(from: newdate ?? Date())
    }
}
//

// 최근 검색어 저장 모델 POST
struct RecentKeywordSaveModel: Codable {
    let token: String
    let words: String
}

// 성공했는지 받는 모델
struct RecentKeywordSaveMessage: Codable {
    let message: String
}
//

// 최근검색어 삭제 모델
struct RecentKeywordDeleteModel: Codable {
    let keywordID: String
    let token: String
    
    enum CodingKeys: String, CodingKey {
        case token
        case keywordID = "keyword_id"
    }
    
}
//
