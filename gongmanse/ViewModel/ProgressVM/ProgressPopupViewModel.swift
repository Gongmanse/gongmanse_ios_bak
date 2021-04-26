//
//  ProgressPopupViewModel.swift
//  gongmanse
//
//  Created by 김우성 on 2021/03/08.
//

import UIKit
enum GradeText: String {
    case element = "초등"
    case middle = "중학"
    case high = "고등"
    case all = "모든"
    
    
}

struct ProgressPopupViewModel {
    let data: String
    
    init(data: String) {
        self.data = data
    }
}

class ProgressMainViewModel {
    
    // ViewModel로 이사 전
    func changeGrade(string: String) -> String {
        var title = ""
        
        if string.hasPrefix("초등") {
            title = "초등"
        }else if string.hasPrefix("중학") {
            title = "중등"
        }else if string.hasPrefix("고등") {
            title = "고등"
        }else {
            title = "모든"
        }
        return title
    }
    
    func changeGradeNumber(string: String) -> Int {
        var numbers = 0
        let arr = ["1","2","3","4","5","6"]
        for i in arr {
            numbers = Int(string.filter{String($0) == String(i)}) ?? 0
            if numbers != 0 {
                break
            }
        }
        return numbers
    }
    
}
