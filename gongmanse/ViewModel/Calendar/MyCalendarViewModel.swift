//
//  MyCalendarViewModel.swift
//  gongmanse
//
//  Created by wallter on 2021/06/04.
//

import Foundation

class MyCalendarViewModel {
    
    var myDate: CalendarMyCalendarModel? = nil
    
    func myCalendarApi(_ date: String) {
        
        let parameter = MyCalendarPostModel(token: Constant.token,
                                            date: date)
        
        CalendarAPIManager.myCalendarApi(parameter) { response in
            switch response {
            case .success(let data):
                self.myDate = data
                
            case .failure(let err):
                print(err.localizedDescription)
            }
        }
    }
}
