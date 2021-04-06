//
//  QuestionListViewModel.swift
//  gongmanse
//
//  Created by taeuk on 2021/04/02.
//

import UIKit
import Alamofire

let questionURL = apiBaseURL+"/v/setting/faqlist"

struct requestQuestionListAPI {
    
    func requestQuetionList(complition: @escaping (_ result: [QuestionList]) -> Void) {
        
        AF.request(questionURL)
            .responseDecodable(of: QustionListModel.self) { response in
                switch response.result {
                case .success(let response):
                    // controller code
                    let json = response
                    let ask = json.data
                    complition(ask)
                    
                case .failure(let error):
                    print("DEBUG: faild connection \(error.localizedDescription)")
                }
            }
    }
    
}

