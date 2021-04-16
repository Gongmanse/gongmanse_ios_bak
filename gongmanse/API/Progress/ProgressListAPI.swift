//
//  RequestProgressAPI.swift
//  gongmanse
//
//  Created by wallter on 2021/04/15.
//

import Foundation
import Alamofire

struct ProgressListAPI {
    
    func requestProgressDataList(complition: @escaping (_ result: [ProgressBodyModel]) -> Void) {
        
        let url = "\(apiBaseURL)/v3/progress/record/34?grade&gradeNum&offset&limit"
        
        AF.request(url, method: .get)
            .responseDecodable(of: ProgressPopupModel.self) { response in
                switch response.result {
                case .success(let json):
                    complition(json.body!)
                case .failure(let error):
                    print("DEBUG: ", error.localizedDescription)
                }
        }
    }
    
}
