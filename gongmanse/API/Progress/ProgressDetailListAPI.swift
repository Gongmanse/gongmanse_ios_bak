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
    var progressIdentifier = ""
    
    // 초기값
    init(progressId: String, limit: Int, offset: Int) {
        detailURL +=  "\(progressId)?offset=\(offset)&limit=\(limit)"
        progressIdentifier = progressId
    }
    
    // 초기 이후 offset개수에 따른 무한스크롤
    init(limit: Int, offset: Int) {
        detailURL += "\(progressIdentifier)?offset=\(offset)&limit=\(limit)"
    }
    
    func requestDetailList(complition: @escaping (_ result: ProgressDetailModel) -> Void) {
        
        AF.request(detailURL, method: .get)
            .responseDecodable(of: ProgressDetailModel.self) { response in
                switch response.result {
                case .success(let data):
                    
                    complition(data)
                case .failure(let error):
                    print("DEBUG == ", error.localizedDescription)
                }
            }
    }
    
}
