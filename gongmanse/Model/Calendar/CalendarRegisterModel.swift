//
//  CalendarRegisterModel.swift
//  gongmanse
//
//  Created by wallter on 2021/06/02.
//

import Foundation

enum RegistRepeat: String {
    case none = "none"
    case daily = "daily"
    case weekly = "weekly"
    case monthly = "monthly"
    case yearly = "yearly"
}

enum RegistAlarm: String {
    case none = "none"
    case rightOnTime = "right_on_time"
    case before10Mins = "before_10_mins"
    case before30Mins = "before_30_mins"
    case before1Hours = "before_1_hours"
    case before3Hours = "before_3_hours"
    case before12Hours = "before_12_hours"
    case before1Day = "before_1_day"
    case before1Week = "before_1_week"
    
}
// 캘린터 추가하기 POST 모델

struct CalendarRegisterModel: Codable {
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

// 응답받는 모델
struct CalendarRegistResponseModel: Codable {
    let message: String
    let data: CalendarResponseDataModel
}

struct CalendarResponseDataModel: Codable {
    let id: Int
}
