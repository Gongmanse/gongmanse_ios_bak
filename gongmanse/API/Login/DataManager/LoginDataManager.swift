//
//  LoginDataManager.swift
//  gongmanse
//
//  Created by 김우성 on 2021/03/29.
//  https://api.gongmanse.com/v1/auth/token

import Foundation
import Alamofire

class LoginDataManager {
    /* 로그인 */
    func sendingLoginInfo(_ parameters: LoginInput, viewController: LoginVC) {
        // Controller에서 휴대전화번호 데이터 받음
        let data = parameters
        
        // 로그인정보 post
        AF.upload(multipartFormData: { MultipartFormData in
            MultipartFormData.append("\(data.usr)".data(using: .utf8)!, withName: "usr")
            MultipartFormData.append("\(data.pwd)".data(using: .utf8)!, withName: "pwd")
            MultipartFormData.append("\(data.grant_type)".data(using: .utf8)!, withName: "grant_type")

        }, to: "\(Constant.BASE_URL)/v1/auth/token")

        // Result를 Response 타입에 맞게 변환
        .responseDecodable(of: LoginResponse.self) { response in
            switch response.result {
            case .success(let response):
                if let token = response.token {
                    // 로그인 성공
                    viewController.didSucceedLogin(token)
                } else {
                    // 로그인 실패
                    viewController.didFaildLogin(response)
                }
                
            case .failure(let error):
                // 연결 실패
                print("DEBUG: failed connection \(error.localizedDescription)")
            }
        }
    }

}
