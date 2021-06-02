//
//  CalendarRegistViewModel.swift
//  gongmanse
//
//  Created by wallter on 2021/06/02.
//

import Foundation

class CalendarRegistViewModel {
    
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
