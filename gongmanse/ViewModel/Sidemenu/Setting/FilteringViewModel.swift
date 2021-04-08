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
        userTokenValue = "YWI0NmU1YzE4MjczOWU4MDYxYWExZWFlNzBmODAxZDg4OWU1ZWU3OGVhYWNmMmExY2Y0YjBjNTZjOTg2NGEwNjcxYTViODI3M2U3NjZiYWE0OGU4NjM1ZWUyNWVmYTI1NDdhM2YwOWMwMDVhMDAxN2E0ZjVjNDQxZmM4ZjlmMTA1VmwwYUNDZjlQVWVyYUplVThSQVgxZkt5N2FUekxjQTFPSUpZUERUZWdLTnVXNjN4TGpaUWg0RUx5OTlOcUdoVm1aK2xnVnl2Yk1PbFJJTHM0TmJ4UT09"
        userGrade = UserDefaults.standard.object(forKey: "gradeFilterText") as? String
        userSubject = UserDefaults.standard.object(forKey: "subjectFilterNumber") as? String
        
        let settingFilter = postFilteringAPI()
        // 안됨
//        settingFilter.performFiltering(userTokenValue, userGrade, userSubject)
        // 됨
        settingFilter.performGetFiltering(token: userTokenValue ?? "", grade: userGrade ?? "", subject: userSubject ?? "")
    }
    
    func resetDefaults() {
        let defaults = UserDefaults.standard
        let dictionary = defaults.dictionaryRepresentation()
        dictionary.keys.forEach { key in
            defaults.removeObject(forKey: key)
        }
    }
    
}
