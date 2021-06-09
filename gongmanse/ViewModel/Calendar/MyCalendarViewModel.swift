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
    //
    
    weak var calendarDelegate: CollectionReloadData?
    
    
    func requestMyCalendarApi(_ date: String) {
        
        let parameter = MyCalendarPostModel(token: Constant.token,
                                            date: date)
        
        CalendarAPIManager.myCalendarApi(parameter) { response in
            switch response {
            case .success(let data):
                
                self.calendarCheckData(data)
                self.calendarDelegate?.reloadCollection()
//                self.myDate = data
                
            case .failure(let err):
                print(err.localizedDescription)
            }
        }
    }
    
    func calendarCheckData(_ data: CalendarMyCalendarModel) {
        
        dateList.removeAll()
        
        for receive in data.data {
            if !receive.description.isEmpty {
                dataArr.append(receive)
                stringConvertDate(receive)
                print(receive)
            }
            
        }
        
    }
    
    var onUpated: () -> Void = {}
    
    func stringConvertDate(_ date: CalendarMyDataModel) {
        
        let dateformatter = DateFormatter()
        dateformatter.locale = Locale(identifier: "ko_KR")
        dateformatter.dateFormat = "yyyy-MM-dd"
        
        print(date.date)
        
        
        if let dateConvert = dateformatter.date(from: date.date) {
            dateList.append(dateConvert)
        }
    }
}

