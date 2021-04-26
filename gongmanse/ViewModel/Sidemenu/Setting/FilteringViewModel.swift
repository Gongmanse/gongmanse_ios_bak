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
        userTokenValue = "ZWNmNzczNjYyMDgzZmQ1ZGU3ODZkNzI2MmU2NGEwY2RhMDliNTM4NWQ3NzhmNDNjYjZiZTE1NzYzYTlkN2M4N2U2YWQxZTdhNjU5ZDI0NDI0YzY5NmIyZGRkOTA2ZDhjNjdlNWJkOWQ5MGE0ODhlZWIzOGMwMThhMGYzN2YxYjI5Zk00OTUzODlhVWRxSHp4dks3UGlKa3laa1lqR2grMUNValdlMkMvMG5HdEZ6b0dyZTB2K0dQZFpoUmhRb0IzcHViTytWSk92cVFxbll2TVNuK1NpZz09"
        userGrade = UserDefaults.standard.object(forKey: "gradeFilterText") as? String
        userSubject = UserDefaults.standard.object(forKey: "subjectFilterNumber") as? String
       
        
        let settingFilter = postFilteringAPI()
        // POST
//        settingFilter.performFiltering(userTokenValue, userGrade, userSubject)
        // Get
        settingFilter.performGetFiltering(token: userTokenValue ?? "", grade: userGrade ?? "", subject: userSubject ?? "")
        
    }
    
    deinit {
        print("filterVM = nil")
    }
}
