//
//  VideoPlaylistResponse.swift
//  gongmanse
//
//  Created by 김우성 on 2021/06/16.
//

import Foundation

struct VideoPlaylistResponse: Codable {
    
    var isMore: Bool
    var totalNum: String
    var seriesInfo: PlayListInfo
    var data: [PlayListData]    
}

struct SeriesVideoPosition: Codable {
    var data: PositionData?
}

struct PositionData: Codable {
    var num: String?
}

struct VideolistResponse: Codable {
    
    var isMore: Bool?
    var totalNum: String
    var seriesInfo: PlayListInfo?
    var data: [VideoData]?
}

struct VideoData: Codable {
    var id: String?
    var iSeriesId: String?
    var video_id: String?
    var sTitle: String?
    var sTags: String?
    var dtDateCreated: String?
    var dtLastModified: String?
    var sSubject: String?
    var sTeacher: String?
    var sSubjectColor: String?
    var sThumbnail: String?
    var sUnit: String?
    var iRating: String?
}

