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
        // Controller에서 데이터 수신
        let data = parameters
        
        // 받은 데이터를 AF를 통한 업로드
        AF.upload(multipartFormData: { MultipartFormData in
            MultipartFormData.append(Data("\(data.username)".utf8), withName: "username")
            MultipartFormData.append(Data("\(data.password)".utf8), withName: "password")
            MultipartFormData.append(Data("\(data.confirm_password)".utf8), withName: "confirm_password")
            MultipartFormData.append(Data("\(data.first_name)".utf8), withName: "first_name")
            MultipartFormData.append(Data("\(data.nickname)".utf8), withName: "nickname")
            MultipartFormData.append(Data("\(data.phone_number)".utf8), withName: "phone_number")
            MultipartFormData.append(Data("\(data.verification_code)".utf8), withName: "verification_code")
            MultipartFormData.append(Data("\(data.email)".utf8), withName: "email")
            MultipartFormData.append(Data("\(data.address1)".utf8), withName: "address1")
            MultipartFormData.append(Data("\(data.address2)".utf8), withName: "address2")
            MultipartFormData.append(Data("\(data.city)".utf8), withName: "city")
            MultipartFormData.append(Data("\(data.zip)".utf8), withName: "zip")
            MultipartFormData.append(Data("\(data.country)".utf8), withName: "country")
        }, to: "\(Constant.BASE_URL)/v1/members")
        
        // Result를 Response 타입에 맞게 변환
        .responseDecodable(of: RegistrationResponse.self) { response in
            switch response.result {
            case .success(let response):
                // 연결 성공
                if response.code == 200 {
                    // 회원가입 성공 시, 성공메세지 전달
                    viewController.didSuccessRegistration(message: response)
                } else {
                    // 화원가입 실패 시, 실패메세지 전달 (실패한 항목이 많으면 그만큼 메세지 항목이 많아짐)
                    viewController.failedToRequest(message: response)
                }
            case .failure(let error):
                // 연결 실패
                print("DEBUG: failed connection \(error.localizedDescription)")
            }
        }
    }
}
