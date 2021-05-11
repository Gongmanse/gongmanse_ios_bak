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
