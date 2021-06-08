//
//  MyCalendarViewModel.swift
//  gongmanse
//
//  Created by wallter on 2021/06/04.
//

import Foundation

class MyCalendarViewModel {
    
    var myDate: CalendarMyCalendarModel? = nil
    
    // Description 값이 있는 데이터만 담을 배열
    var dataArr: [CalendarMyDataModel] = []
    
    
    var dateList: [Date] = []
    
    func requestMyCalendarApi(_ date: String) {
        
        let parameter = MyCalendarPostModel(token: Constant.token,
                                            date: date)
        
        CalendarAPIManager.myCalendarApi(parameter) { response in
            switch response {
            case .success(let data):
                print(data)
                self.calendarCheckData(data)
//                self.myDate = data
                
            case .failure(let err):
                print(err.localizedDescription)
            }
        }
    }
    
    func calendarCheckData(_ data: CalendarMyCalendarModel) {
        
        for receive in data.data {
            if !receive.description.isEmpty {
                dataArr.append(receive)
                stringConvertDate(receive)
                print(receive)
            }
            
        }
        
    }
    
    func stringConvertDate(_ date: CalendarMyDataModel) {
        
        dateList.removeAll()
        
        let dateformatter = DateFormatter()
        dateformatter.locale = Locale(identifier: "ko_KR")
        dateformatter.dateFormat = "yyyy-MM-dd"
        
        print(date.date)
        
        
        if var dateConvert = dateformatter.date(from: date.date) {
            print("stringConverDate: ", dateConvert)
            dateConvert.addTimeInterval(32400)
            dateList.append(dateConvert)
            
        }
    }
}
