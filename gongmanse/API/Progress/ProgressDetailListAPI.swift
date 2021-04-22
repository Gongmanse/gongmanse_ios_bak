//
//  ProgressDetailListAPI.swift
//  gongmanse
//
//  Created by wallter on 2021/04/16.
//

import Foundation
import Alamofire

struct ProgressDetailListAPI {
    
    var detailURL = "\(apiBaseURL)/\(ProgressAPI.progress)/detail/"
    
    // 초기값
    init(progressId: String, limit: Int, offset: Int) {
        detailURL +=  "\(progressId)?offset=\(offset)&limit=\(limit)"
        
    }
    
    func requestDetailList(complition: @escaping (_ result: ProgressDetailModel) -> Void) {
        
        AF.request(detailURL, method: .get)
            .responseDecodable(of: ProgressDetailModel.self) { response in
                switch response.result {
                case .success(let data):
                    print(data)
                    complition(data)
                case .failure(let error):
                    print("DEBUG == ", error.localizedDescription)
                }
            }
    }
    
}
