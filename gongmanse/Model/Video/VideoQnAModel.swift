//
//  VideoQnAModel.swift
//  gongmanse
//
//  Created by wallter on 2021/05/14.
//

import Foundation

// 동영상 QnA 모델
struct VideoQnAModel: Codable {
    let totalNum: String
    var data: [VideoQnADataModel]
}

struct VideoQnADataModel: Codable {
    
    let sQid: String?
    let sQuestion: String?
    let dtRegister: String?
    let sAnswer: String?
    let sNickname: String?
    var sTeacher: String?
    let sUserImg: String?
    let sTeacherImg: String?
    
    func copy() throws -> VideoQnADataModel {
        let data = try JSONEncoder().encode(self)
        let copy = try JSONDecoder().decode(VideoQnADataModel.self, from: data)
        return copy
    }
}
//

// 동영상 POST 모델 ( 강의 추가 )
struct VideoQnAPostModel: Codable {
    let videoID: String
    let token: String
    let content: String
    
    enum CondingKeys: String, CodingKey {
        case videoID = "video_id"
        case token, content
    }
}


struct HomeSeriesModel: Codable {
    let totalNum: String
    let data: [HomeSeriesDataModel]
}

struct HomeSeriesDataModel: Codable {
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
