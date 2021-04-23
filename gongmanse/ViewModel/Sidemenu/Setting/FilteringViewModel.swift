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
        userTokenValue = "MzcyMjFmZDExYTEzZDA2MmFkZTE1ZDRiNjhiNDZkOTlkYzhjZWFlZmZkOGE3NWJmYmViMGIwZTJkNzU0MmZlNWQyNmIxMDJkYjdiZmUxZTliMTg4OGRlODg4Zjc0NzI4MGM1OWQyNTA5ZjlmODgwZGIzODA3NTNhYzA2MTg1MjY4OXdJRnMwM3lLTEFDOTlSNXMvMjVKLzZqd2lCNGZlbjJBYTNydFJsWXJGZkhTN0NteEJFaW1tUlR0UGwyc0p5dXBkSmJRYXB0OFhOOGg5MmRMVDhFQT09"
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
