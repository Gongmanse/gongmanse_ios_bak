//
//  LoginGetProfileManager.swift
//  gongmanse
//
//  Created by wallter on 2021/05/18.
//

import Foundation
import Alamofire

struct LoginGetProfileManager {
    
    func profileGetApi(_ token: String, completion: @escaping resultModel<LoginGetProfile> ) {
        
        let url = "\(apiBaseURL)/v/member/getuserinfo?token=\(Constant.token)"
        
        AF.request(url)
            .responseDecodable(of: LoginGetProfile.self) { response in
                switch response.result {
                case .success(let data):
                    completion(.success(data))
                case .failure(_):
                    completion(.failure(.noRequest))
                }
            }
    }
}
