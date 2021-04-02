//
//  QuestionListViewModel.swift
//  gongmanse
//
//  Created by taeuk on 2021/04/02.
//

import Foundation
import Alamofire

let questionURL = "https://api.gongmanse.com/v/setting/faqlist"

struct requestQuestionListAPI {
    
    func requestQuetionList(complition: @escaping () -> Void) {
        AF.request(questionURL, method: .get, encoding: JSONEncoding.default)
        
    }
}

