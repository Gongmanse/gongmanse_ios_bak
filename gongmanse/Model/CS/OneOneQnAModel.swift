//
//  OneOneQnAModel.swift
//  gongmanse
//
//  Created by wallter on 2021/06/16.
//

import Foundation

// 1:1문의 목록 조회 GET
struct OneOneQnAList: Codable {
    let data: [OneOneQnADataList]
}

struct OneOneQnADataList: Codable {
    let id: String
    let iType: String
    let sQuestion: String
    let sQdatecreated: String
    let sAnswer: String?
    let sStatus: String
    let sAdatecreated: String?
}

// 1:1문의 등록 POST
struct OneOneQnARegist: Codable {
    let token: String
    let question: String
    let type: String
}

// 1:1문의 수정 PATCH


// 1:1문의 삭제 POST
struct OneOneQnADelete: Codable {
    let id: String
}
