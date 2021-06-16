//
//  CalendarMyCalendarModel.swift
//  gongmanse
//
//  Created by wallter on 2021/06/04.
//

import Foundation


// 내 캘린더 데이터 받을 모델
struct CalendarMyCalendarModel: Codable {
    
    let data: [CalendarMyDataModel]
}

struct CalendarMyDataModel: Codable {
    let date: String
    var description: [CalendarMyDescriptionModel]
}


struct CalendarMyDescriptionModel: Codable {
    let id: String
    let eType: String
    let iWholeDay: String
    let dtStartDate: String
    let dtEndDate: String
    let sTitle: String
    let sDescription: String?
    let sAlarmCode: String?
    let sRepeatCode: String?
    let sRepeatRadioCode: String?
    let iRepeatUseEndDate: String
    let dtDateCreated: String
    let sWebImage: String?
    let sMobileImage: String?
    let iViews: String
    let iActive: String
    
    var alarmCode: String {
        switch sAlarmCode {
        case "none":
            return "없음"
        case "before_10_mins":
            return "10분 전"
        case "before_30_mins":
            return "30분 전"
        case "before_1_hours":
            return "1시간 전"
        case "before_3_hours":
            return "3시간 전"
        case "before_12_hours":
            return "12시간 전"
        case "before_1_day":
            return "1일 전"
        case "before_1_week":
            return "1주 전"
        default:
            return "없음"
        }
    }
    
    var repeatCode: String {
        switch sRepeatCode {
        case "none":
            return "없음"
        case "daily":
            return "매일"
        case "weekly":
            return "매주"
        case "monthly":
            return "매달"
        case "yearly":
            return "매년"
        default:
            return "없음"
        }
    }
}
//

// 내 캘린더 POST 모델

struct MyCalendarPostModel: Codable {
    let token: String
    let date: String
}
