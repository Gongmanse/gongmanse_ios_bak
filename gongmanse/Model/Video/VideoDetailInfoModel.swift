//
//  VideoDetailInfoModel.swift
//  gongmanse
//
//  Created by wallter on 2021/05/27.
//

import Foundation

// 동영상 상세정보

struct VideoDetailInfoModel: Codable {
    let data: VideoDetailInfoDataModel
}

struct VideoDetailInfoDataModel: Codable {
    let id: String
    let sTitle: String
    let iHasCommentary: String
    let iSeriesId: String
    let iCommentaryId: String
//    let sTags: String
//    let sTeacher: String
//    let dtDateCreated: String
//    let dtLastModified: String
//    let iRating: String
//    let iRatingNum: String
//    let sHighlight: String
//    let sBookmarks: String
//    let sThumbnail: String
//    let sVideopath: String
//    let sSubtitle: String
//    let sUnit: String
//    let iUserRating: String?
//    let sSubject: String
//    let sSubjectColor: String
    let iCategoryId: String
    let source_url: String?
    
}
//
