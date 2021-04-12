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
        userTokenValue = "ZmFlYzFjM2FhM2ZkMzdiYmU0YTFkZWMzYzUxNDJkZWQwNzFkMjQwYWI3YjU0NzE1MDE0MWRhZThhM2Y4ZjJkNzY5ZjU4OWFjZjYxMTBmZTAyZWVhYmY4ZjRjOTQ2YWZlMzhmZGZiODZhYWNlZmQzMWNjODVjZDk1NmUyYzdhYmVCTHBqWmdSZzBDY0lkVUJ5VnBGR05nd1ZPK3V4ck1xd1JuaTROc1NjSkY0NGFVa05wVDcvUVdSclV5WXpyNUh5Z0RuZEJldkZFTUM3RXo5dDg1UnFhUT09"
        userGrade = UserDefaults.standard.object(forKey: "gradeFilterText") as? String
        userSubject = UserDefaults.standard.object(forKey: "subjectFilterNumber") as? String
       
        
        let settingFilter = postFilteringAPI()
        // 안됨
//        settingFilter.performFiltering(userTokenValue, userGrade, userSubject)
        // 됨
        settingFilter.performGetFiltering(token: userTokenValue ?? "", grade: userGrade ?? "", subject: userSubject ?? "")
        
    }
    
}
