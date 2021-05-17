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
    let data: [VideoQnADataModel]
}

struct VideoQnADataModel: Codable {
    
    let sQid: String?
    let sQuestion: String?
    let dtRegister: String?
    let sAnswer: String?
    let sNickname: String?
    let sTeacher: String?
    let sUserImg: String?
    let sTeacherImg: String?
    
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
