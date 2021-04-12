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
        userTokenValue = "N2RlNDFkOGVhODYyOGE3MmY5NWZiZGQyZjg5MmIwNDc2YTRiZDIzNzZmNTFhZjZhYmNhMTdhMDc3ZDU0MjI2MjVmYmFlZTlmNTViMzY1ZmUyZjI1Yzg2NWNmMWQyOGJkOTUyYWJhNGUzMzRiYTEwNWQwMGQ3ODMyNjI5ZWMzYjNKanM1ZFlRQkZmdk1LZ2kzMVpsMiswaGczdHVuZG50NVl2Y1JhZmJLeFNtSzVoVVoxb0h0cUEyTWZWRk5VZ0ZOWjU0ek0xbldMMlJUN3hNdGZMN3BZUT09"
        userGrade = UserDefaults.standard.object(forKey: "gradeFilterText") as? String
        userSubject = UserDefaults.standard.object(forKey: "subjectFilterNumber") as? String
        print(userGrade)
        print(userSubject)
        let settingFilter = postFilteringAPI()
        // 안됨
//        settingFilter.performFiltering(userTokenValue, userGrade, userSubject)
        // 됨
        settingFilter.performGetFiltering(token: userTokenValue ?? "", grade: userGrade ?? "", subject: userSubject ?? "")
    }
    
    // userdefaults reset
    func resetDefaults() {
        let defaults = UserDefaults.standard
        let dictionary = defaults.dictionaryRepresentation()
        dictionary.keys.forEach { key in
            defaults.removeObject(forKey: key)
        }
    }
    
}
