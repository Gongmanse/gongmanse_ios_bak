//
//  EditingProfileDataManager.swift
//  gongmanse
//
//  Created by 김우성 on 2021/06/01.
//

import Alamofire
import UIKit


class EditingProfileDataManager {
    func getProfileInfoFromAPI(_ parameters: EditingProfileInput, viewController: EditingProfileController) {
        
        let data = parameters
        let url = "https://api.gongmanse.com/v/member/getuserinfo?token=\(data.token)"
        URLCache.shared.removeAllCachedResponses()

        /// HTTP Method: GET
        /// API 명: "01010. 프로필 정보 조회"
        AF.request(url)
            .responseDecodable(of: EditingProfileResponse.self) { response in
                
                switch response.result {
                case .success(let response):
                    viewController.didSuccessNetworing(response: response)
                    
                case .failure(let error):
                    print("DEBUG: 프로필데이터 수신 API 통신 실패")
                    print("DEBUG: faild connection \(error.localizedDescription)")
                }
            }
    }
    
    func getProfileInfoFromAPIAtSideMenu(_ parameters: EditingProfileInput, viewController: SideMenuVC) {
        
        let data = parameters
        let url = "https://api.gongmanse.com/v/member/getuserinfo?token=\(data.token)"
        
        
        URLCache.shared.removeAllCachedResponses()

        /// HTTP Method: GET
        /// API 명: "01010. 프로필 정보 조회"
        AF.request(url)
            .responseDecodable(of: EditingProfileResponse.self) { response in
                
                switch response.result {
                case .success(let response):
                    viewController.didSuccessNetworing(response: response)
                    
                case .failure(let error):
                    print("DEBUG: 프로필데이터 수신 API 통신 실패")
                    print("DEBUG: faild connection \(error.localizedDescription)")
                }
            }
    }
    
    func getProfileInfoFromAPIAtSideMenu(_ parameters: EditingProfileInput, completion: @escaping (_ response: EditingProfileResponse) -> Void) {
        
        let data = parameters
        let url = "https://api.gongmanse.com/v/member/getuserinfo?token=\(data.token)"
        
        
        URLCache.shared.removeAllCachedResponses()

        /// HTTP Method: GET
        /// API 명: "01010. 프로필 정보 조회"
        AF.request(url)
            .responseDecodable(of: EditingProfileResponse.self) { response in
                
                switch response.result {
                case .success(let response):
                    completion(response)
                    
                case .failure(let error):
                    print("DEBUG: 프로필데이터 수신 API 통신 실패")
                    print("DEBUG: faild connection \(error.localizedDescription)")
                }
            }
    }
    
    func getPremiumDateFromAPI(_ parameters: EditingProfileInput, viewController: LoginVC) {
        
        let data = parameters
        let url = "https://api.gongmanse.com/v/member/getuserinfo?token=\(data.token)"
        


        
        URLCache.shared.removeAllCachedResponses()

        /// HTTP Method: GET
        /// API 명: "01010. 프로필 정보 조회"
        AF.request(url)
            .responseDecodable(of: EditingProfileResponse.self) { response in
                
                switch response.result {
                case .success(let response):
                    viewController.didSuccessNetworing(response: response)
                    
                case .failure(let error):
                    print("DEBUG: 프로필데이터 수신 API 통신 실패")
                    print("DEBUG: faild connection \(error.localizedDescription)")
                }
            }
    }
    
    func getUserId(_ token: String, _ fcm_token: String) {
        let url = "https://api.gongmanse.com/v/member/userid?token=\(token)"
        URLCache.shared.removeAllCachedResponses()

        /// HTTP Method: GET
        /// API 명: "01010. 프로필 정보 조회"
        AF.request(url)
            .responseDecodable(of: UserData.self) { response in
                
                switch response.result {
                case .success(let response):
                    self.registerFcmToken(fcm_token, response.user_id)
                    
                case .failure(let error):
                    print("DEBUG: 프로필데이터 수신 API 통신 실패")
                    print("DEBUG: faild connection \(error.localizedDescription)")
                }
            }
    }
    
    func registerFcmToken(_ token: String, _ user_id: String) {
        let url = "\(Constant.BASE_URL)/v1/push_notification/mobile_devices"
        // 아이디를 post
        AF.upload(multipartFormData: { MultipartFormData in
            MultipartFormData.append("\(token)".data(using: .utf8)!, withName: "token")
            MultipartFormData.append("\(user_id)".data(using: .utf8)!, withName: "user_id")
            MultipartFormData.append("Ios".data(using: .utf8)!, withName: "os_type")
        }, to: url)

        // Result를 Response 타입에 맞게 변환
        .responseString { response in
            print("DEBUG: FCM Token API Response \(response)")
        }
    }
    
}


