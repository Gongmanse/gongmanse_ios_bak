//
//  CalendarRegistViewModel.swift
//  gongmanse
//
//  Created by wallter on 2021/06/02.
//
import Foundation


class CalendarRegistViewModel {
    
    
    // 등록관련
    
    var allDaySwitch: Dynamic<Bool> = Dynamic(false)
    
    func currentStartDate() -> String {
        let dateformatter: DateFormatter = DateFormatter()
        dateformatter.dateFormat = "yyyy-MM-dd"
        
        let timeformatter: DateFormatter = DateFormatter()
        timeformatter.dateFormat = "HH:mm"
        
        
        let dateString = dateformatter.string(from: Date())
        let timeString = timeformatter.string(from: Date())
        
        let allCurrent = "\(dateString) \(timeString)"
        
        return allCurrent
    }
    
    func currentEndDate() -> String {
        let dateformatter: DateFormatter = DateFormatter()
        dateformatter.dateFormat = "yyyy-MM-dd"
        
        let timeformatter: DateFormatter = DateFormatter()
        timeformatter.dateFormat = "HH:mm"
        
        let dateString = dateformatter.string(from: Date())
        let timeString = timeformatter.string(from: Date(timeIntervalSinceNow: 600))
        
        let allCurrent = "\(dateString) \(timeString)"
        
        return allCurrent
    }
    
    func alarmConvertString(_ alarm: String) -> String {
        switch alarm {
        case "없음":
            return alarmString.none.convert
        case "정시":
            return alarmString.rightTime.convert
        case "10분 전":
            return alarmString.before10m.convert
        case "30분 전":
            return alarmString.bofore30m.convert
        case "1시간 전":
            return alarmString.before1h.convert
        case "3시간 전":
            return alarmString.before3h.convert
        case "12시간 전":
            return alarmString.before12h.convert
        case "1일 전":
            return alarmString.before1d.convert
        case "1주 전":
            return alarmString.before1w.convert
        default:
            return ""
        }
    }
    
    func repeatConvertString(_ repeatText: String) -> String {
        switch repeatText {
        case "없음":
            return repeatString.none.rawValue
        case "매일":
            return repeatString.daily.rawValue
        case "매주":
            return repeatString.weekly.rawValue
        case "매달":
            return repeatString.monthly.rawValue
        case "매년":
            return repeatString.yearly.rawValue
        default:
            return ""
        }
    }
    
    /// 일정 추가하기
    func requestRegistApi(title: String,
                          content: String,
                          wholeDay: String,
                          startDate: String,
                          endDate: String,
                          alarm: String?,
                          repeatAlarm: String?,
                          repeatCount: String?) {
        
        var startDateVariable: String = ""
        var endDateVariable: String = ""
        
        startDateVariable = startDate
        endDateVariable = endDate
        
        if wholeDay == "1" {
            let startFormatter = DateFormatter()
            startFormatter.dateFormat = "yyyy-MM-dd 00:00"
            
            let endFormatter = DateFormatter()
            endFormatter.dateFormat = "yyyy-MM-dd 23:59"
            
            startDateVariable = startFormatter.string(from: Date())
            endDateVariable = endFormatter.string(from: Date())
            
            print(startDateVariable)
            print(endDateVariable)
        }
        
        let parameter = CalendarRegisterModel(token: Constant.token,
                                              title: title,
                                              content: content,
                                              isWholeDay: wholeDay,
                                              startDate: startDateVariable,
                                              endDate: endDateVariable,
                                              alarm: alarm ?? "none",
                                              repeatAlaram: repeatAlarm ?? "none",
                                              repeatCount: repeatCount ?? "0")
        
        CalendarAPIManager.calendarRegisterApi(parameter) { (response) in
            switch response {
            case .success(let data):
                print(data)
                NotificationCenter.default.post(name: NSNotification.Name("calendar"), object: nil)
            case .failure(let err):
                print(err.localizedDescription)
            }
        }
    }
    
    /// 일정 업데이트
    func requestUpdateApi(updateID: String,
                          title: String,
                          content: String,
                          iswholeDay: String,
                          startDate: String,
                          endDate: String,
                          alarm: String?,
                          repeatAlarm: String?,
                          repeatCount: String?) {
        
        let parameter = CalendarUpdatePostModel(id: updateID,
                                                token: Constant.token,
                                                title: title,
                                                content: content,
                                                isWholeDay: iswholeDay,
                                                startDate: startDate,
                                                endDate: endDate,
                                                alarm: alarm ?? "",
                                                repeatAlaram: repeatAlarm ?? "",
                                                repeatCount: repeatCount ?? "")
        
        CalendarAPIManager.calendarUpdateApi(parameter) {
            print("🗣 Success Update Calendar")
            NotificationCenter.default.post(name: NSNotification.Name("calendar"), object: nil)
        }
    }
    
    
    func requestDeleteApi(deleteId: String) {
        
        let parameter = CalendarDeletePostModel(id: deleteId)
        
        CalendarAPIManager.calendarDeleteApi(parameter) {
            print("Calendar Delete Success")
        }
    }
}
