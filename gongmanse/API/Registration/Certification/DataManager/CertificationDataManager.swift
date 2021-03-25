//
//  CertificationDataManager.swift
//  gongmanse
//
//  Created by 김우성 on 2021/03/23.
//


import Alamofire

class CertificationDataManager {
    /* 인증번호 */
    func sendingNumber(_ parameters: CertificationNumberInput, viewController: CheckUserIdentificationVC) {
        
        // Controller에서 휴대전화번호 데이터 받음
        let data = viewController.userInfoData.phone_number
        
        // 휴대전화번호를 post
        AF.upload(multipartFormData: { MultipartFormData in
            MultipartFormData.append("\(data)".data(using: .utf8)!, withName: "phone_number")

        }, to: "\(Constant.BASE_URL)/v1/sms/verifications")

        // Result를 Response 타입에 맞게 변환
        .responseDecodable(of: CertificationNumberResponses.self) { response in
            switch response.result {
            case .success(let response):
                // 연결 성공
                if response.message == "ok" {
                    // 정상적으로 전달시, 아래로직 진행 (확인결과, 아무숫자나 넣어도 무조건 ok 뜸)
                    viewController.didSendingNumber(response: response)
                } else {
                    // 특정 형식에 대해서 유효성검사하지 않기에, 무조건 .success로 빠지게됨.
                }
            case .failure(let error):
                // 연결 실패
                print("DEBUG: failed connection \(error.localizedDescription)")
            }
        }
    }
    
    /* 아이디 중복여부 확인 */
    func idDuplicateCheck(_ parameters: idDuplicateCheckInput, viewController: RegistrationUserInfoVC) {
        
        // Controller에서 휴대전화번호 데이터 받음
        // 클릭할 때마다 실행됨.
        let data = viewController.viewModel.username
        
        // 아이디를 post
        AF.upload(multipartFormData: { MultipartFormData in
            MultipartFormData.append("\(data!)".data(using: .utf8)!, withName: "username")
        }, to: "\(Constant.BASE_URL)/v/member/duplication_username")

        // Result를 Response 타입에 맞게 변환
        .responseDecodable(of: idDuplicateCheckResponse.self) { response in
            switch response.result {
            case .success(let response):
                // 연결 성공
                if response.data == "0" {
                    // 아이디가 중복되지 않음.
                    viewController.idDuplicationCheckInVC(message: response)
                    
                } else {
                    // 아이디가 중복됨.
                    viewController.idDuplicationCheckInVC(message: response)
                    
                }
            case .failure(let error):
                // 연결 실패
                print("DEBUG: failed connection \(error.localizedDescription)")
            }
        }
    }

    /* 닉네임 중복 여부 */
    func nicknameDuplicateCheck(_ parameters: nicknameDulicateCheckInput, viewController: RegistrationUserInfoVC) {
        let data = viewController.viewModel.nickname
        
        AF.upload(multipartFormData: { MultipartFormData in
            MultipartFormData.append("\(data!)".data(using: .utf8)!, withName: "nickname")
        }, to: "\(Constant.BASE_URL)/v/member/duplication_nickname")

        .responseDecodable(of: nicknameDuplicateCheckResponse.self) { response in
            switch response.result {
            case .success(let response): // 연결 성공
                if response.data == "0" {
                    viewController.nicknameDuplicationCheckInVC(message: response)
                } else {
                    viewController.nicknameDuplicationCheckInVC(message: response)
                }
            case .failure(let error):
                print("DEBUG: failed connection \(error.localizedDescription)")
            }
        }
    }
    
}

