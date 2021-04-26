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
        userTokenValue = "NWI0NjRiZDU0YTgyYjFhZTU1OGRmZDljZjBlYThmMDNmNWU0OTc1YjgyODNkMGM5ZDYxYjMzOWIyYTc2OGQxZTkxYWM4ZTk2ZTczMGExZTMwY2UwYzcxNWU0MGI3YjA0NzRmODVhZTE0NTc3ODQyMWIyZjQyM2JiOWU3OWY0MjNqbUFESlhOT1VhREFPQVdqZUErWUlGSkhyZU91Y3BSR2JWcmZyVG1kTTRCYTlaejhlSWdQanl4VUF6b1QrR3Bjb0tzRythdTlGMVY5QzJzZ3NmQTVkUT09"
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
