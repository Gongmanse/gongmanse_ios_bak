//
//  SearchNotesModel.swift
//  gongmanse
//
//  Created by wallter on 2021/05/06.
//

import Foundation

struct SearchNotesModel: Codable {
    let totalNum: String
    let data: [SearchNotesDataModel]
}

struct SearchNotesDataModel: Codable {
    
    let videoID: String?
    let iSeriesId: String?
    let sTitle: String?
    let iRating: String?
    let sTeacher: String?
    let sSubjectColor: String?
    let sSubject: String?
    let sThumbnail: String?
    
    enum CodingKeys: String, CodingKey {
        case videoID = "video_id"
        case iSeriesId, sTitle, iRating, sTeacher, sSubjectColor, sSubject, sThumbnail
    }
}


// post시 모델

struct SearchNotesPostModel {
    
    let subject: String?
    let grade: String?
    let keyword: String?
    let offset: String?
    let sortID: String?
    
    enum CodingKeys: String, CodingKey {
        case subject, grade, keyword, offset
        case sortID = "sort_id"
    }
}
