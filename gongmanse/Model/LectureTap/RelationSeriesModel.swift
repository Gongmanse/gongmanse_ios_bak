//
//  RelationSeriesModel.swift
//  gongmanse
//
//  Created by wallter on 2021/05/25.
//

import Foundation

// 관련시리즈 모델
struct RelationSeriesModel: Codable {
    let isMore: Bool
    let totalNum: String
    let seriesInfo: RelationSeriesInfo?
    let data: [RelationSeriesDataModel]
}

struct RelationSeriesInfo: Codable {
    let sTitle: String
    let sTeacher: String
    let sSubjectColor: String
    let sSubject: String
    let sGrade: String
}

struct RelationSeriesDataModel: Codable {
    let id: String
    let sTitle: String
    let dtDateCreated: String
    let dtLastModified: String
    let sSubject: String
    let sTeacher: String
    let sSubjectColor: String
    let sThumbnail: String
    let sUnit: String
}
//
