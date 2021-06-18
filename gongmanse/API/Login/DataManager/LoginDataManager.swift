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
        let userID = data.usr
        
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
                // 로그인 성공
                if let refreshToken = response.refresh_token {
                    Constant.refreshToken = refreshToken
                }
                
                if let token = response.token {
                    
                    viewController.didSucceedLogin(token, userID: userID)
                    Constant.token = token
                    
                } else { // 로그인 실패
                    
                    viewController.didFaildLogin(response)
                }
                
            case .failure(let error):
                // 연결 실패
                print("DEBUG: failed connection \(error.localizedDescription)")
            }
        }
    }
    
    /* 자동로그인 */
    func getTokenByRefreshToken(_ parameters: RefreshTokenInput) {
        // Controller에서 휴대전화번호 데이터 받음
        let refreshToken = parameters.refresh_token
        let grantType = parameters.grant_type
        
        // 로그인정보 post
        AF.upload(multipartFormData: { MultipartFormData in
            MultipartFormData.append("\(refreshToken)".data(using: .utf8)!, withName: "refresh_token")
            MultipartFormData.append("\(grantType)".data(using: .utf8)!, withName: "grant_type")
            
        }, to: "\(Constant.BASE_URL)/v1/auth/token")

        // Result를 Response 타입에 맞게 변환
        .responseDecodable(of: RefreshTokenResponse.self) { response in
            switch response.result {
            case .success(let response):
                print("DEBUG: 리프레쉬토큰을 이용한 토큰은 \(response.token) 입니다.")
                Constant.token = response.token
                
            case .failure(let error):
                // 연결 실패
                print("DEBUG: failed connection \(error.localizedDescription)")
                Constant.refreshToken = ""
            }
        }
    }

}

struct RefreshTokenInput: Encodable {
    
    var grant_type: String
    var refresh_token: String
}

struct RefreshTokenResponse: Decodable {
    
    var token: String
}
