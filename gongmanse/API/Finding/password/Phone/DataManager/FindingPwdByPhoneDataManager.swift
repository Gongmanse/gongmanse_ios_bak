//
//  FindingPwdByPhoneDataManager.swift
//  gongmanse
//
//  Created by 김우성 on 2021/04/01.
//


import Foundation
import Alamofire

class FindingPwdByPhoneDataManager {
    
    /* 휴대전화로 찾기 - 인증번호 */
    func certificationNumberByPhone(_ parameters: ByPhoneInput, viewController: FindingPwdByPhoneVC) {
        // viewModel -> paramters 를 통해 값을 전달
        let data = parameters
        
        // Input Data Type
        let param: Parameters = [
            "receiver_type": "cellphone",
            "receiver": "\(data.receiver)",
            "name": "\(data.name)"
        ]
        
        // 입력 정보 .PUT
        AF.request("\(Constant.BASE_URL)/v1/recovery", method: .put, parameters: param, encoding: JSONEncoding.default, headers: nil)
            .responseDecodable(of: ByPhoneResponse.self) { response in
                switch response.result {
                case .success(let response):
                    viewController.didSucceedCertificationNumber(response: response)
                    
                case .failure(let error):
                    print("DEBUG: faild connection \(error.localizedDescription)")
                }
            }
    }
    
    
    /* 아이디 찾기 결과 - 휴대전화로 찾기 */
    func findingIDResultByPhone(_ parameters: FindingIDResultInput, viewController: FindingPwdByPhoneVC) {
        // viewModel -> paramters 를 통해 값을 전달
        let data = parameters
        
        // 휴대전화로 찾기
        AF.request("\(Constant.BASE_URL)/v/member/recoverid?receiver_type=cellphone&receiver=\(data.receiver)&name=\(data.name)")
                    .responseDecodable(of: FindingPwdByPhoneResponse.self) { response in
                        switch response.result {
                        case .success(let response):
                            viewController.didSucceedSendingID(response: response)
                        case .failure(let error):
                            print("DEBUG: faild connection \(error.localizedDescription)")
                        }
                    }
    }

}











