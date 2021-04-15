//
//  LectureListModel.swift
//  gongmanse
//
//  Created by wallter on 2021/04/14.
//

import Foundation

struct LectureListModel: Codable {
    let totalNum: String
    let data: [LectureThumbnail]
}

struct LectureThumbnail: Codable {
    let sThumbnail: String
    
    var fullthumbnail: String {
        return "\(fileBaseURL)/\(sThumbnail)"
    }
}
