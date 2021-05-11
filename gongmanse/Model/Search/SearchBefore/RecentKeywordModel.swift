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
