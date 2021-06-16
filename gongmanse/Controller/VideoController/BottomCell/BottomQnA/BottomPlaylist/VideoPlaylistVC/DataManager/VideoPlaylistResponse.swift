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


