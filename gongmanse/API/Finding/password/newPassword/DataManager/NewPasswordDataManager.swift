//
//  NewPasswordDataManager.swift
//  gongmanse
//
//  Created by 김우성 on 2021/04/01.
//

import Foundation
import Alamofire

class NewPasswordDataManager {
    
    /// 비밀번호 변경 API메소드
    /// - json으로 송신 시, 정상적으로 비밀번호가 변경되지 않음
    /// - formdata로 메소드 구성 시, 정상적으로 비밀번호가 변경됨
    func changePassword(_ parameters: NewPasswordInput, viewController: NewPasswordVC) {
        // Controller에서 데이터 수신
        let data = parameters

        // 받은 데이터를 AF를 통한 업로드
        AF.upload(multipartFormData: { MultipartFormData in
            MultipartFormData.append(Data("\(data.username)".utf8), withName: "username")
            MultipartFormData.append(Data("\(data.password)".utf8), withName: "password")
        }, to: "\(Constant.BASE_URL)/v/member/updatepw")

        // Result를 Response 타입에 맞게 변환
        .responseDecodable(of: NewPasswordResponse.self) { response in

            switch response.result {
            case .success(let response):
                // 연결 성공
                if response.code == 200 {
                    // 회원가입 성공 시, 성공메세지 전달
                    print("DEBUG: \(#function) 성공")
                    viewController.didSucceed(response: response)

                } else {
                    // 화원가입 실패 시, 실패메세지 전달 (실패한 항목이 많으면 그만큼 메세지 항목이 많아짐)
                    print("DEBUG: falid changing Password")
                }

            case .failure(let error):
                // 연결 실패
                print("DEBUG: failed connection \(error.localizedDescription)")
            }
        }

        // viewModel -> paramters 를 통해 값을 전달
//        let data = parameters
//
//        print("DEBUG: API로 보내는 아이디 \(data.username)")
//        print("DEBUG: API로 보내는 비밀번호 \(data.password)")
//
//        // Input Data Type
//        let param: Parameters = [
//            "username": data.username,
//            "password": data.password
//        ]
//
//        // 입력 정보 .PUT
//        AF.request("\(Constant.BASE_URL)/v/member/updatepw", method: .post, parameters: param, encoding: JSONEncoding.default, headers: nil)
//            .responseDecodable(of: NewPasswordResponse.self) { response in
//
//                switch response.result {
//                case .success(let response):
//                    // 연결 성공
//                    if response.code == 200 {
//                        // 회원가입 성공 시, 성공메세지 전달
//
//                        print("DEBUG: \(#function) 성공 ")
//                        print("DEBUG: \(response)")
//                        viewController.didSucceed(response: response)
//
//                    } else {
//                        // 화원가입 실패 시, 실패메세지 전달 (실패한 항목이 많으면 그만큼 메세지 항목이 많아짐)
//                        print("DEBUG: falid changing Password")
//                    }
//
//                case .failure(let error):
//                    // 연결 실패
//                    print("DEBUG: failed connection \(error.localizedDescription)")
//                }
//            }
//
        
    }
}
