//
//  SubjectModel.swift
//  gongmanse
//
//  Created by wallter on 2021/04/07.
//

import Foundation

// 과목 리스트 받아오는 모델
struct SubjectListModel: Codable {
    
    let data: [SubjectModel]
    
}

struct SubjectModel: Codable {
    let id: String
    let sName: String
}


// 토큰 학년 과목 보내는 모델
struct SubejectFilterModel: Decodable {
    
    var token: String
    var grade: String
    var subject: String
    
}

// 토큰 학년 과목을 보내고 다시 받아오는 모델
struct SubjectGetDataListModel: Codable {
    let data: SubjectGetDataModel
}

struct SubjectGetDataModel: Codable {
    let sGrade: String
    let iPreferCategory: Int
    let sName: String
}
