//
//  SearchAfterVideoAPIManager.swift
//  gongmanse
//
//  Created by wallter on 2021/04/30.
//

import Foundation
import Alamofire

struct SearchAfterVideoAPIManager {
    
    let videoUrl = "https://api.gongmanse.com/v/search/searchbar"
    
    func fetchVideoAPI(_ parameters: SearchVideoPostModel,
                       completion: @escaping (Result<SearchVideoModel, InfoError>) -> Void ) {
        
        let data = parameters
        print("SearchAfterVideoAPIManager == ", data)
        AF.upload(multipartFormData: { formData in
            
            formData.append("\(data.subject ?? "")".data(using: .utf8) ?? Data(), withName: "subject")
            formData.append("\(data.grade ?? "")".data(using: .utf8) ?? Data(), withName: "grade")
            formData.append("\(data.keyword ?? "")".data(using: .utf8) ?? Data(), withName: "keyword")
            formData.append("\(data.offset ?? "0")".data(using: .utf8) ?? Data(), withName: "offset")
            formData.append("\(data.sortid ?? "")".data(using: .utf8) ?? Data(), withName: "sort_id")
            formData.append("\(data.limit ?? "20")".data(using: .utf8) ?? Data(), withName: "limit")
//            formData.append("0".data(using: .utf8) ?? Data(), withName: "subject")
//            formData.append("중등".data(using: .utf8) ?? Data(), withName: "grade")
//            formData.append("무신".data(using: .utf8) ?? Data(), withName: "keyword")
//            formData.append("0".data(using: .utf8) ?? Data(), withName: "offset")
//            formData.append("1".data(using: .utf8) ?? Data(), withName: "sort_id")
//            formData.append("20".data(using: .utf8) ?? Data(), withName: "limit")
        }, to: videoUrl)
        
        .responseDecodable(of: SearchVideoModel.self) { response in
            switch response.result {
            case .success(let data):
                completion(.success(data))
            case .failure(_):
                completion(.failure(.noRequest))
            }
        }
    }
}
