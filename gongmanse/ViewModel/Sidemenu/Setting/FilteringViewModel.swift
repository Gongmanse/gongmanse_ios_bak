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
        userTokenValue = "NjU0YWM3NzI1ZGM3ZWIyYzlmMTg5YmY2MmZkYTQ3Y2YwYWUyNWY1Yjk0YjllMDQxOTc5YjZlMDA3YmQ1NWI4YmFlNmZjNWQyZWVmZGUxZTdjNzU2MmEzOTU1ZTk0ZmYzOWNiNzg0NmFmMTk1ZWI4MjQ3YzkyNmYwMWMzZWM4ODhmcWR4Zm05RHliU0l0aHlnbUhtRVgwOVQxcjE1aEtvdW1NWHdKRmZUTTQyS3RYYm9KQko0M0FnNHdOME5vbVZ6elgxdlFxeWdpeFNpVkdHb2g4VkJ6dz09"
        userGrade = UserDefaults.standard.object(forKey: "gradeFilterText") as? String
        userSubject = UserDefaults.standard.object(forKey: "subjectFilterText") as? String
        
        let ttt = postFilteringAPI()
//        ttt.performFiltering(userTokenValue, userGrade, userSubject)
        ttt.performGetFiltering(token: userTokenValue ?? "", grade: userGrade ?? "", subject: userSubject ?? "")
    }
    
    func resetDefaults() {
        let defaults = UserDefaults.standard
        let dictionary = defaults.dictionaryRepresentation()
        dictionary.keys.forEach { key in
            defaults.removeObject(forKey: key)
        }
    }
    
}
