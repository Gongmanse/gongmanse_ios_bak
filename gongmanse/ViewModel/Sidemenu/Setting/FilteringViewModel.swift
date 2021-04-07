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
        userTokenValue = "MTM0NzQ2ZTIxOGNmM2Y1NmI4NTExYWMwODEzYzRmMDg5YmI5YzIzN2FlODE4NTExNTY1NTFkOGEzMmIzN2VkYTFmNjdkYjQ0OTU5MjQxNWM0OWQ1NDRmZDEwYmE0ZWEwYmU4NjkyYzgwNjdiMWU1YTUyNjg0NTI2NGU1YzJiYzVZTnY4SVcvaFhOM2J3Zm5mUDVvTFFsVlNWNDAzTi8zZUtGbzRVZHBYc1o0OUhndVN6NzFOL2d4eXFCWkxOMkZSdkJiL1lLMlBsSlJTZ2F6OTFyckU4QT09"
        userGrade = UserDefaults.standard.object(forKey: "gradeFilterText") as? String
        userSubject = UserDefaults.standard.object(forKey: "subjectFilterText") as? String
        
        let ttt = postFilteringAPI()
        ttt.performFiltering(userTokenValue, userGrade, userSubject)
    }
    
    func resetDefaults() {
        let defaults = UserDefaults.standard
        let dictionary = defaults.dictionaryRepresentation()
        dictionary.keys.forEach { key in
            defaults.removeObject(forKey: key)
        }
    }
    
}
