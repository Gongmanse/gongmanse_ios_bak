//
//  CalendarMyCalendarModel.swift
//  gongmanse
//
//  Created by wallter on 2021/06/04.
//

import Foundation


// 내 캘린더 데이터 받을 모델
struct CalendarMyCalendarModel: Codable {
    
    let data: [CalendarMyDatamodel]
}

struct CalendarMyDatamodel: Codable {
    let date: String
    let description: [CalendarMyDescriptionModel]
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
    
}
//

// 내 캘린더 POST 모델

struct MyCalendarPostModel: Codable {
    let token: String
    let date: String
}
