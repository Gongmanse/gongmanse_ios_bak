//
//  LectureModel.swift
//  gongmanse
//
//  Created by wallter on 2021/05/17.
//

import Foundation

struct LectureModel: Codable {
    let totalNum: String
    let data: [LectureDataModel]
}

struct LectureDataModel: Codable {
    let sGrade: String
    let sTitle: String
    let id: String
    let sTeacher: String
    let sSubject: String
    let sSubjectColor: String
    let sThumbnail: String
}
