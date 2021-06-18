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
    var data: [LectureDataModel]
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
//

// 강사별 보기 세 번째 화면
struct SeriesDetailModel: Codable {
    let isMore: Bool?
    let totalNum: String?
    let seriesInfo: SeriesInfoModel?
    var data: [SeriesDetailDataModel]
}

struct SeriesInfoModel: Codable {
    let sTitle: String?
    let sTeacher: String?
    let sSubjectColor: String?
    let sSubject: String?
    let sGrade: String?
}

struct SeriesDetailDataModel: Codable {
    let id: String?
    let iSeriesId: String?
    let sTitle: String?
    let dtDateCreated: String?
    let dtLastModified: String?
    let sSubject: String?
    let sTeacher: String?
    let sSubjectColor: String?
    let sThumbnail: String?
    let sUnit: String?
}
