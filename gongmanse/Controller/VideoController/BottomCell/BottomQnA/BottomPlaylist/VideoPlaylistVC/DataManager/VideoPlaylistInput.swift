//
//  VideoPlaylistInput.swift
//  gongmanse
//
//  Created by 김우성 on 2021/06/16.
//

import Foundation

struct VideoPlaylistInput: Encodable {
    
    var seriesID: String
    var offset: String
    var limit: String
    
    enum CodingKeys: String, CodingKey {
        case offset
        case seriesID = "series_id"
        case limit
    }
}
