//
//  ProgressDetailListAPI.swift
//  gongmanse
//
//  Created by wallter on 2021/04/16.
//

import Foundation
import Alamofire

struct ProgressDetailListAPI {
    
    let detailURL: String?
    var progressIdentifier = 0
    
    // 초기값
    init(progressId: Int, limit: Int, offset: Int) {
        detailURL = "\(apiBaseURL)/v3/progress/detail/\(progressId)?offset=\(offset)&limit=\(limit)"
        
    }
    
    // 초기 이후 offset개수에 따른 무한스크롤
    init(limit: Int, offset: Int) {
        detailURL = "\(apiBaseURL)/v3/progress/detail/\(progressIdentifier)?offset=\(offset)&limit=\(limit)"
    }
    
    func requestDetailList(complition: @escaping (_ result: [ProgressDetailBody]) -> Void) {
        
        AF.request(detailURL ?? "", method: .get)
            .responseDecodable(of: ProgressDetailModel.self) { response in
                switch response.result {
                case .success(let data):
                    
                    complition(data.body!)
                case .failure(let error):
                    print("DEBUG == ", error.localizedDescription)
                }
            }
    }
    
}
