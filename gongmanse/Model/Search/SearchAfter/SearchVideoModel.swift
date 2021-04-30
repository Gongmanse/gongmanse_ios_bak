//
//  SearchVideoModel.swift
//  gongmanse
//
//  Created by wallter on 2021/04/30.
//

import Foundation

// 동영상 백과 검색 결과 API 모델

struct SearchVideoModel {
    let totalNum: String
    let data: [SearchVideoDataModel]
}


struct SearchVideoDataModel {
    let id: String?
    let iSeriesId: String?
    let sTitle: String?
    let sTags: String?
    let iRating: String?
    let sTeacher: String?
    let sSubjectColor: String?
    let sSubject: String?
    let dtDateCreated: String?
    let dtLastModified: String?
    let sThumbnail: String?
}
