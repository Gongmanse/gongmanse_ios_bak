//
//  CalendarUpdateModel.swift
//  gongmanse
//
//  Created by wallter on 2021/06/14.
//

import Foundation

struct CalendarUpdatePostModel: Codable {
    let id: String
    let token: String
    let title: String
    let content: String
    let isWholeDay: String
    let startDate: String
    let endDate: String
    let alarm: String
    let repeatAlaram: String
    let repeatCount: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case token
        case title
        case content
        case isWholeDay = "is_whole_day"
        case startDate = "start_date"
        case endDate = "end_date"
        case alarm
        case repeatAlaram = "repeat"
        case repeatCount = "repeat_count"
    }
}
