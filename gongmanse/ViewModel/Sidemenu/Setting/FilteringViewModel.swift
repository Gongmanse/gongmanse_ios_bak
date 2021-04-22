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
        userTokenValue = "YTQwMjhiMmIxZWI0NWFjNzg2YTE4MzFkMTIyMzc3ZWNlZDI4NGJjODlmMTNiZTM2MmM1OWIzNTQ3Njc1Y2IxZWI5MmJiOTg5NTg1MmRlN2Q5YWE1NDMxYzI2OTg0ZmMzNTU4Zjg0M2Y0MWMxOWUyOTYxZjIzMDVmNzU1ODE0Y2VSVHVZMVhFVDRXOW84UUIrM0Vsd1I2eEtaNWFoY2U1RWhSMFJTQ0hDWVpHUFd2RUx3c2tJMi9Ud0NGN2FVZ0NwVmRJcHRqYWp6WmlRRHY3WXRucHpqQT09"
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
