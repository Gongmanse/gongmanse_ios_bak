//
//  OneOneAPIManager.swift
//  gongmanse
//
//  Created by wallter on 2021/06/16.
//

import Foundation
import Alamofire

struct OneOneAPIManager {
    
    /// 1:1 문의 목록 가져오는 API
    static func fetchOneOneListApi( completion: @escaping resultModel<OneOneQnAList>) {
        
        let oneOneListUrl = "\(apiBaseURL)/v/setting/personalqna?token=\(Constant.token)"
        
        AF.request(oneOneListUrl, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil)
            .responseDecodable(of: OneOneQnAList.self) { response in
                switch response.result {
                case .success(let data):
                    completion(.success(data))
                case .failure(_):
                    completion(.failure(.noRequest))
                }
            }
    }
    
    /// 1:1 문의 등록하기 API
    static func fetchOneOneRegistApi(_ parameter: OneOneQnARegist, completion: @escaping () -> Void) {
        
        let registUrl = "\(apiBaseURL)/v/setting/personalqna"
        
        let data = parameter
        
        AF.upload(multipartFormData: {
            $0.append(data.token.data(using: .utf8)!, withName: "token")
            $0.append(data.question.data(using: .utf8)!, withName: "question")
            $0.append(data.type.data(using: .utf8)!, withName: "type")
        }, to: registUrl)
        .response { response in
            switch response.result {
            case.success(_):
                completion()
            case .failure(_):
                completion()
            }
        }
    }
    /// 1:1 문의 업데이트 API
    static func fetchOneOneUpdateApi(_ parameter: OneOneQnAUpdate, completion: @escaping () -> Void) {
        let updateUrl = "\(apiBaseURL)/v/setting/personalqna"
        
        let param: Parameters = [
            "token"     : Constant.token,
            "id"        : parameter.id,
            "question"  : parameter.question,
            "type"      : parameter.type
        ]
        
        AF.request(updateUrl,
                   method: .patch,
                   parameters: param,
                   encoding: JSONEncoding.prettyPrinted,
                   headers: nil,
                   interceptor: nil,
                   requestModifier: nil)
            
            .response { result in
                switch result.result {
                case .success(_):
                    completion()
                case .failure(_):
                    completion()
                }
            }
        
        
    }
    /// 1:1 문의 삭제하기 API
    static func fetchOneOneDeleteApi(_ parameter: OneOneQnADelete, completion: @escaping () -> Void) {
        
        let deleteUrl = "\(apiBaseURL)/v/setting/deleteqna"
        
        let data = parameter
        
        AF.upload(multipartFormData: {
            $0.append(data.id.data(using: .utf8)!, withName: "id")
        }, to: deleteUrl)
        .response { response in
            switch response.result {
            case .success(_):
                completion()
            case .failure(_):
                completion()
            }
        }
    }
}
