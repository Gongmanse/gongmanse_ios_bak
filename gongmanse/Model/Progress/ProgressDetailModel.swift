//
//  ProgressDetailModel.swift
//  gongmanse
//
//  Created by wallter on 2021/04/16.
//

import Foundation
// Progress 상세 전체모델
struct ProgressDetailModel: Codable {
    
    let header: ProgressDetailHeader?
    let body: [ProgressDetailBody]?
    
}
// Progress header 모델
struct ProgressDetailHeader: Codable {
    let resultMsg: String?
    let totalRows: String?
    let isMore: String?
    let label: ProgressDetailHeaderLabel?
}
// Progress header label 모델
struct ProgressDetailHeaderLabel: Codable {
    let title: String?
    let grade: String?
    let subject: String?
    let subjectColor: String?
}
// Progress body 모델
struct ProgressDetailBody: Codable {
    let videoId: String?
    let progressId: String?
    let title: String?
    let subject: String?
    let subjectColor: String?
    let teacherName: String?
    let thumbnail: String?
    let unit: String?
    let rating: String?
    let createdDate: String?
    let lastModified: String?
    
    var teacherChangeName: String {
        return "\(teacherName ?? "") 선생님"
    }
}
