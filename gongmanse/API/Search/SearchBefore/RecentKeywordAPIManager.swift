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
        let listUrl = "\(apiBaseURL)/v/member/mysearches?token=\(Constant.token)"
        
        AF.request(listUrl, method: .get)
            .responseDecodable(of: RecentKeywordModel.self) { response in
                switch response.result {
                case .success(let data):
                    completion(.success(data))
                case .failure(_):
                    completion(.failure(.noRequest))
                }
            }
    }
    
    func fetchKeywordSaveApi(_ parameter: RecentKeywordSaveModel,
                             completion: @escaping resultModel<RecentKeywordSaveMessage>) {
        let data = parameter
        
        let saveUrl = "https://api.gongmanse.com/v1/searches"
        
        AF.upload(multipartFormData: {
            $0.append(data.token.data(using: .utf8) ?? Data(), withName: "token")
            $0.append(data.words.data(using: .utf8) ?? Data(), withName: "words")
        }, to: saveUrl)
        
        .responseDecodable(of: RecentKeywordSaveMessage.self) { response in
            switch response.result {
            case .success(let data):
                completion(.success(data))
            case .failure(_):
                completion(.failure(.noRequest))
            }
        }
    }
    
    func fetchKeywordDeleteApi(_ parameter: RecentKeywordDeleteModel,
                               completion: @escaping resultModel<RecentKeywordDeleteModel>) {
        
        let data = parameter
        
        let deleteUrl = "https://api.gongmanse.com/v/search/mysearches"
        
        AF.upload(multipartFormData: {
            $0.append(data.keywordID.data(using: .utf8) ?? Data(), withName: "keyword_id")
            $0.append(data.token.data(using: .utf8) ?? Data(), withName: "token")
        }, to: deleteUrl)
        
        .responseDecodable(of: RecentKeywordDeleteModel.self) { response in
            switch response.result {
            case .success(let data):
                completion(.success(data))
            case.failure(_):
                completion(.failure(.noRequest))
            }
        }
    }
}
