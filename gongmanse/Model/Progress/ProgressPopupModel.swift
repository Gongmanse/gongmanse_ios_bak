//
//  ProgressPopupModel.swift
//  gongmanse
//
//  Created by 김우성 on 2021/03/08.
//
enum subGrade: String {
    case element = "초등", middle = "중등", high = "고등"
}

import Foundation

// 프로그레스 전체 모델
struct ProgressPopupModel: Codable {
    let header: ResultProgressModel?
    let body: [ProgressBodyModel]?
}
// 반환값 받아오는 모델
struct ResultProgressModel: Codable {
    let resultMsg: String
    let totalRows: String
    let isMore: String
}

// progress 바디 모델
struct ProgressBodyModel: Codable {
    let progressId: String?
    let title: String?
    let grade: String?
    let gradeNum: String?
    let gradeNum2: String?
    let gradeNum3: String?
    let subject: String?
    let subjectColor: String?
    let totalRows: String?
    
    
    var totalLecture: String {
        return "총 \(totalRows ?? "")강"
    }
    
}
