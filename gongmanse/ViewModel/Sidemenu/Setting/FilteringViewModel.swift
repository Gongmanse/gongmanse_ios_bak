//
//  FilteringViewModel.swift
//  gongmanse
//
//  Created by wallter on 2021/04/07.
//

import UIKit

class FilteringViewModel {
    
    var userTokenValue: String?
    var userGrade: String?
    var userSubject: String?
    
    
    func postData() {
        userTokenValue = "OTdmOWNjNmMwNjQ0MTQzZDI1OWFjMmYyNWJmNzFjZGE0Y2Q2ZjA5NDU0ZWQzYzVhNmM2MDM2MWMyYzJlZTM4MDkzYzdkZjE5YjUwOGEyMWE3YjZiNDdhMDBhYjA1MzM4NDZiN2EzNmZjMWI1ZWM4Y2M5OTRlZDRjYTMxOWFjNWJnRytTeTR6cVRZQXF1Ykx1K2t0RWhjWS9aeW9PT0VONzZkTUtGa3o1NHJQUlAvL01xampUR3IrSlhmNldSQ0FzNkgwQzBpUUJSbFdrZVVxeGh0dzRjZz09"
        userGrade = UserDefaults.standard.object(forKey: "gradeFilterText") as? String
        userSubject = UserDefaults.standard.object(forKey: "subjectFilterNumber") as? String
       
        
        let settingFilter = postFilteringAPI()
        // POST
//        settingFilter.performFiltering(userTokenValue, userGrade, userSubject)
        // Get
        settingFilter.performGetFiltering(token: userTokenValue ?? "", grade: userGrade ?? "", subject: userSubject ?? "")
        
    }
    
}
