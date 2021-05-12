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
        
        userGrade = UserDefaults.standard.object(forKey: "gradeFilterText") as? String
        userSubject = UserDefaults.standard.object(forKey: "subjectFilterNumber") as? String
        
        let settingFilter = postFilteringAPI()
        // POST
//        settingFilter.performFiltering(userTokenValue, userGrade, userSubject)
        // Get
        settingFilter.performGetFiltering(token: Constant.testToken, grade: userGrade ?? "", subject: userSubject ?? "")
        
    }
    
    deinit {
        print("filterVM = nil")
    }
}
