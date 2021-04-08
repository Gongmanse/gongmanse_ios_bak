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
//


// 토큰 학년 과목 보내는 모델
struct SubejectFilterModel {
    
    let token: String
    let grade: String
    let subject: String
    
}

// post방식 토큰 학년 과목을 보내고 데이터 받아오는 모델
struct SubjectGetDataListModel: Codable {
    let data: SubjectGetDataModel
}

struct SubjectGetDataModel: Codable {
    let sGrade: String
    let iPreferCategory: String
    let sName: String
}
//


//get 방식 서버보내기 ( 현재 사용중 )

struct getFilteringAPIModel: Codable {
    let token: String
    let grade: String
    let subject: String
    
}
