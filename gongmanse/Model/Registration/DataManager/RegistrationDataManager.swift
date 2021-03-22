//
//  RegistrationDataManager.swift
//  gongmanse
//
//  Created by 김우성 on 2021/03/22.
//
// AF.request("\(Constant.BASE_URL)/v1/members")

import Alamofire

class RegistrationDataManager {
    func signUp(_ parameters: RegistrationInput, viewController: CheckUserIdentificationVC) {
        AF.upload(multipartFormData: { MultipartFormData in
            MultipartFormData.append(Data("username".utf8), withName: "username")
            MultipartFormData.append(Data("password".utf8), withName: "password")
            MultipartFormData.append(Data("confirm_password".utf8), withName: "confirm_password")
            MultipartFormData.append(Data("first_name".utf8), withName: "first_name")
            MultipartFormData.append(Data("nickname".utf8), withName: "nickname")
            MultipartFormData.append(Data("phone_number".utf8), withName: "phone_number")
            MultipartFormData.append(Data("verification_code".utf8), withName: "verification_code")
            MultipartFormData.append(Data("email".utf8), withName: "email")
            MultipartFormData.append(Data("address1".utf8), withName: "address1")
            MultipartFormData.append(Data("address2".utf8), withName: "address2")
            MultipartFormData.append(Data("city".utf8), withName: "city")
            MultipartFormData.append(Data("zip".utf8), withName: "zip")
            MultipartFormData.append(Data("country".utf8), withName: "country")
            
        }, to: "\(Constant.BASE_URL)/v1/members")
        .responseDecodable(of: RegistrationResponse.self) { response in
            print("DEBUG: \(response)")
        }
        
        
        
//        AF.request("\(Constant.BASE_URL)/v1/members", method: .post, parameters: parameters, encoder: JSONParameterEncoder(), headers: nil)
////            .validate()
//            .responseDecodable(of: RegistrationResponse.self) { response in
//
//                switch response.result {
//                case .success(let response):
//                    // 연결 성공
//                    if response.code == 200 {
//                        // 회원가입 성공 시, 성공메세지 전달
//                        print("DEBUG: Success Registration...")
//                        viewController.didSuccessRegistration(message: response.message)
//                    } else {
//                        // 화원가입 실패 시, 실패메세지 전달 (실패한 항목이 많으면 그만큼 메세지 항목이 많아짐)
//                        print("DEBUG: failed Registration...")
//                        print("DEBUG: \(response.errors!))")
////                        viewController.failedToRequest(message: response.message)
//                    }
//                case .failure(let error):
//                    // 연결 실패
//                    print("DEBUG: failed connection: \(error.localizedDescription)")
//                    viewController.failedToRequest(message: "서버와의 연결이 원활하지 않습니다")
//                }
//            }
    }
}
//
//import Alamofire
//
//class RegistrationDataManager {
//    func signUp(_ parameters: RegistrationInput, viewController: CheckUserIdentificationVC) {
//        AF.request("\(Constant.BASE_URL)/v1/members", method: .post, parameters: parameters, encoder: JSONParameterEncoder(), headers: nil)
////            .validate()
//            .responseDecodable(of: RegistrationResponse.self) { response in
//
//                switch response.result {
//                case .success(let response):
//                    // 연결 성공
//                    if response.code == 200 {
//                        // 회원가입 성공 시, 성공메세지 전달
//                        print("DEBUG: Success Registration...")
//                        viewController.didSuccessRegistration(message: response.message)
//                    } else {
//                        // 화원가입 실패 시, 실패메세지 전달 (실패한 항목이 많으면 그만큼 메세지 항목이 많아짐)
//                        print("DEBUG: failed Registration...")
//                        print("DEBUG: \(response.errors!))")
////                        viewController.failedToRequest(message: response.message)
//                    }
//                case .failure(let error):
//                    // 연결 실패
//                    print("DEBUG: failed connection: \(error.localizedDescription)")
//                    viewController.failedToRequest(message: "서버와의 연결이 원활하지 않습니다")
//                }
//            }
//    }
//}
