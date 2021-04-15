//
//  RequestProgressAPI.swift
//  gongmanse
//
//  Created by wallter on 2021/04/15.
//

import Foundation
import Alamofire

struct ProgressListAPI {
    
    func requestProgressDataList() {
        
        let url = "\(apiBaseURL)/v3/progress/record/34?grade&gradeNum&offset&limit"
        
        AF.request(url, method: .get)
            .responseDecodable(of: ProgressPopupModel.self) { response in
                switch response.result {
                case .success(let json):
                    print(json.header)
                case .failure(let error):
                    print("DEBUG: ", error.localizedDescription)
                }
        }
    }
    
}
