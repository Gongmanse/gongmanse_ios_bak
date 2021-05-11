//
//  RecentKeywordAPIManager.swift
//  gongmanse
//
//  Created by wallter on 2021/05/11.
//

import Foundation
import Alamofire

struct RecentKeywordAPIManager {
    
    func fetchRecentKeywordListApi(completion: @escaping resultModel<RecentKeywordModel>) {
        let listUrl = "\(apiBaseURL)/v/member/mysearches?token=\(Constant.testToken)"
        
        AF.request(listUrl, method: .get)
            .responseDecodable(of: RecentKeywordModel.self) { response in
                switch response.result {
                case .success(let data):
                    completion(.success(data))
                case .failure(let err):
                    completion(.failure(.noRequest))
                }
            }
    }
}
