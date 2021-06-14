//
//  CalendarAPIManager.swift
//  gongmanse
//
//  Created by wallter on 2021/06/02.
//

import Foundation
import Alamofire

struct CalendarAPIManager {
    
    static func myCalendarApi(_ parameter: MyCalendarPostModel,
                              completion: @escaping resultModel<CalendarMyCalendarModel>) {
    
        let data = parameter
        print(data)
        
        let calendarUrl = "\(apiBaseURL)/v/calendar/mycalendar"
        
        AF.upload(multipartFormData: {
            $0.append("\(data.token)".data(using: .utf8)!, withName: "token")
            $0.append("\(data.date)".data(using: .utf8)!, withName: "date")
        }, to: calendarUrl)
        
        .responseDecodable(of: CalendarMyCalendarModel.self) { response in
            switch response.result {
            case .success(let data):
                completion(.success(data))
            case .failure(_):
                completion(.failure(.noRequest))
            }
        }
    }
    
    
    static func calendarRegisterApi(_ parameter: CalendarRegisterModel,
                                    completion: @escaping resultModel<CalendarRegistResponseModel>) {
        
        let data = parameter
        print(data)
        let registUrl = "\(apiBaseURL)/v1/my/calendar/events"
        
        AF.upload(multipartFormData: {
            $0.append("\(Constant.token)".data(using: .utf8)!, withName: "token")
            $0.append("\(data.title)".data(using: .utf8)!, withName: "title")
            $0.append("\(data.content)".data(using: .utf8)!, withName: "content")
            $0.append("\(data.isWholeDay)".data(using: .utf8)!, withName: "is_whole_day")
            $0.append("\(data.startDate)".data(using: .utf8)!, withName: "start_date")
            $0.append("\(data.endDate)".data(using: .utf8)!, withName: "end_date")
            $0.append("\(data.alarm)".data(using: .utf8)!, withName: "alarm")
            $0.append("\(data.repeatAlaram)".data(using: .utf8)!, withName: "repeat")
            $0.append("\(data.repeatCount)".data(using: .utf8)!, withName: "repeat_count")
            
        }, to: registUrl)
        
        .responseDecodable(of: CalendarRegistResponseModel.self) { response in
            
            switch response.result {
            case .success(let data):
                completion(.success(data))
            case .failure(let err):
                switch response.response?.statusCode {
                case 400:
                    print("400: ", err.localizedDescription)
                case 401:
                    print("401: Author", err.localizedDescription)
                default:
                    print("Unknown err")
                }
                completion(.failure(.noRequest))
                
            }
        }
    }
    
    static func calendarUpdateApi(_ parameter: CalendarUpdatePostModel, completion: @escaping () -> Void) {
        let data = parameter
        
        let updateUrl = "\(apiBaseURL)/v/calendar/editcalendar"
        print(data)
        
        AF.upload(multipartFormData: {
            $0.append(data.id.data(using: .utf8)!, withName: "id")
            $0.append("\(Constant.token)".data(using: .utf8)!, withName: "token")
            $0.append("\(data.title)".data(using: .utf8)!, withName: "title")
            $0.append("\(data.content)".data(using: .utf8)!, withName: "content")
            $0.append("\(data.isWholeDay)".data(using: .utf8)!, withName: "is_whole_day")
            $0.append("\(data.startDate)".data(using: .utf8)!, withName: "start_date")
            $0.append("\(data.endDate)".data(using: .utf8)!, withName: "end_date")
            $0.append("\(data.alarm)".data(using: .utf8)!, withName: "alarm")
            $0.append("\(data.repeatAlaram)".data(using: .utf8)!, withName: "repeat")
            $0.append("\(data.repeatCount)".data(using: .utf8)!, withName: "repeat_count")
        }, to: updateUrl)
        
        .response { response in
            switch response.result {
            case .success(_):
                completion()
            case .failure(let err):
                print(err.localizedDescription)
                completion()
            }
        }
    }
    
    static func calendarDeleteApi(_ parameter: CalendarDeletePostModel, completion: @escaping () -> Void) {
        let data = parameter
        
        let deleteUrl = "\(apiBaseURL)/v/calendar/modifycalendar"
        print(data)
        
        AF.upload(multipartFormData: {
            $0.append(data.id.data(using: .utf8)!, withName: "id")
        }, to: deleteUrl)
        
        .response { response in
            switch response.result {
            case .success(_):
                completion()
            case .failure(_):
                completion()
            }
        }
    }
}
