//
//  LectureModel.swift
//  gongmanse
//
//  Created by wallter on 2021/05/17.
//

import Foundation

// 강사별보기 처음화면
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
//

// 강사별보기 두 번째 화면

struct LectureSeriesModel: Codable {
    let totalNum: Int
    let data: [LectureSeriesDataModel]
}

struct LectureSeriesDataModel: Codable {
    let sTitle: String?
    let sTeacher: String?
    let iSeriesId: String?
    let videoID: String?
    let iCount: String?
    let sSubjectColor: String?
    let sSubject: String?
    let dtDateCreated: String?
    let dtLastModified: String?
    let sThumbnail: String?
    
    enum CodingKeys: String, CodingKey {
        case sTitle
        case sTeacher
        case iSeriesId
        case videoID = "video_id"
        case iCount
        case sSubjectColor
        case sSubject
        case dtDateCreated
        case dtLastModified
        case sThumbnail
    }
}
