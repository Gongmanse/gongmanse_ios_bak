//
//  QustionListModel.swift
//  gongmanse
//
//  Created by taeuk on 2021/04/01.
//

import Foundation

// 통신 후 다시 넣을 데이터모델
struct FrequentlyQnA {
    
    let questionMark = "Q."
    let AskMark = "A."
    
    let id: String
    let question: String
    let Ask: String
    var expanState: Bool
}


// JSON API
struct QustionListModel: Codable {
    
    let data: [QuestionList]
}

struct QuestionList: Codable {
    
    let id: String
    let sQuestion: String
    let sAnswer: String

}
