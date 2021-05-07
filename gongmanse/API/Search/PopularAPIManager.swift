//
//  PopularAPIManager.swift
//  gongmanse
//
//  Created by wallter on 2021/04/28.
//


import UIKit
import Alamofire


enum InfoError: Swift.Error {
    case noRequest
    case noData
}


struct PopularAPIManager {
    let popularURL = "https://api.gongmanse.com/v/video/trending_keyword"
    
    func fetchPopularAPI(completion: @escaping resultModel<PopularKeywordModel>) {
        
        AF.request(popularURL, method: .get)
            .responseDecodable(of: PopularKeywordModel.self) { response in
                switch response.result {
                
                case .success(let data):
                    completion(.success(data))
                case .failure(_):
                    completion(.failure(.noRequest))
                }
            }
    }
}
