//
//  CalendarRegistViewModel.swift
//  gongmanse
//
//  Created by wallter on 2021/06/02.
//

import Foundation

class CalendarRegistViewModel {
    
    
    // 등록관련
    
    func isWriteTitle(_ text: String) -> Bool {
        return text != "" && text.count != 0 ? true : false
    }
    
    func currentStartDate() -> String {
        let dateformatter: DateFormatter = DateFormatter()
        dateformatter.dateFormat = "yyyy. MM. dd"
        
        let dayformatter: DateFormatter = DateFormatter()
        dayformatter.dateFormat = "EE"
        dayformatter.locale = Locale(identifier: "ko_KR")
        
        
        let timeformatter: DateFormatter = DateFormatter()
        timeformatter.dateFormat = "HH:mm"
        
        
        let dateString = dateformatter.string(from: Date())
        let dayString = dayformatter.string(from: Date())
        let timeString = timeformatter.string(from: Date())
        
        let allCurrent = "\(dateString) (\(dayString)) \(timeString)"
        
        return allCurrent
    }
    
    func currentEndDate() -> String {
        let dateformatter: DateFormatter = DateFormatter()
        dateformatter.dateFormat = "yyyy. MM. dd"
        
        let dayformatter: DateFormatter = DateFormatter()
        dayformatter.dateFormat = "EE"
        dayformatter.locale = Locale(identifier: "ko_KR")
        
        
        let timeformatter: DateFormatter = DateFormatter()
        timeformatter.dateFormat = "HH:mm"
        
        let dateString = dateformatter.string(from: Date())
        let dayString = dayformatter.string(from: Date())
        let timeString = timeformatter.string(from: Date(timeIntervalSinceNow: 600))
        
        let allCurrent = "\(dateString) (\(dayString)) \(timeString)"
        
        return allCurrent
    }
    
    // API 불러오기
    func requestRegistApi(title: String,
                          content: String,
                          wholeDay: String,
                          startDate: String,
                          endDate: String,
                          alarm: String,
                          repeatAlarm: String,
                          repeatCount: String) {
        
        let parameter = CalendarRegisterModel(token: Constant.token,
                                              title: title,
                                              content: content,
                                              isWholeDay: wholeDay,
                                              startDate: startDate,
                                              endDate: endDate,
                                              alarm: alarm,
                                              repeatAlaram: repeatAlarm,
                                              repeatCount: repeatCount)
        
        CalendarAPIManager.calendarRegisterApi(parameter) { (response) in
            switch response {
            case .success(let data):
                print(data)
            case .failure(let err):
                print(err.localizedDescription)
            }
        }
    }
}
