//
//  Enum+CalendarConvert.swift
//  gongmanse
//
//  Created by wallter on 2021/06/16.
//

import Foundation

enum alarmString {
    case none
    case rightTime
    case before10m
    case bofore30m
    case before1h
    case before3h
    case before12h
    case before1d
    case before1w
    
    var convert: String {
        switch self {
        case .none:
            return "none"
        case .rightTime:
            return "right_on_time"
        case .before10m:
            return "before_10_mins"
        case .bofore30m:
            return "before_30_mins"
        case .before1h:
            return "before_1_hours"
        case .before3h:
            return "before_3_hours"
        case .before12h:
            return "before_12_hours"
        case .before1d:
            return "before_1_day"
        case .before1w:
            return "before_1_week"
        }
    }
}

enum repeatString: String {
    case none = "none"
    case daily = "daily"
    case weekly = "weekly"
    case monthly = "monthly"
    case yearly = "yearly"
}
