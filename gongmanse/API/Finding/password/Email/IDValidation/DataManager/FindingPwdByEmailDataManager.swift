//
//  FindingPwdByEmailDataManager.swift
//  gongmanse
//
//  Created by 김우성 on 2021/04/01.
//

import Foundation
import Alamofire

class FindingPwdByEmailDataManager {
    
    /* 아이디 찾기 결과 - 이메일로 찾기 */
    func findingIDResultByEmail(_ parameters: FindingPwdByEmailInput, viewController: FindingPwdByEmailVC) {
        // viewModel -> paramters 를 통해 값을 전달
        let data = parameters
        
        // 이메일로 찾기
        let urlString = "https://api.gongmanse.com/v/member/recoverid?receiver_type=email&receiver=\(data.receiver)&name=\(data.name)"
        if let encoded = urlString.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed),let url = URL(string: encoded)
        {
            AF.request(url)
                .responseDecodable(of: FindingPwdByEmailResponse.self) { response in
                    switch response.result {
                    case .success(let response):
                        // controller code
                        viewController.didSucceedSendingID(response: response)
                    case .failure(let error):
                        print("DEBUG: faild connection \(error.localizedDescription)")
                    }
                }
        }
    }
    
    /* 이메일로 찾기 - 인증번호 */
    func certificationNumberByEmail(_ parameters: ByEmailInput, viewController: FindingPwdByEmailVC) {
        // 이메일 및 유저정보를 받아온다.
        let data = parameters
        
        let param: Parameters = [
            "receiver_type": "email",
            "receiver": "\(data.receiver)",
            "name": "\(data.name)"
        ]
        
        // 입력 정보 .PUT
        /*
         구성방식)
         1. 데이터를 put으로 전송한다.
         2. response를 가져온다.
         3. 가져온 response 중에서  "로 시작하는 곳 부터 } 로 끝나는 곳까지 string을 슬라이싱한다.
         4. 그 값과 유저가 받은 인증번호를 비교하여 일치여부를 확인한다,
         */
        AF.request("\(Constant.BASE_URL)/v1/recovery", method: .put, parameters: param, encoding: URLEncoding.httpBody, headers: nil, interceptor: nil, requestModifier: nil)
            .responseData { response in
                switch response.result {
                case .success:
                    let text = response.debugDescription            // 서버 로그까지 포함된 데이터
                    viewController.didSucceedReceiveNumber(response: text)
                    
                case .failure:
                    // 이름이나 이메일을 잘못 작성한 경우 해당 로직이 실행된다.
                    viewController.didFaildSendingCertificationNumber()
                    print("DEBUG: failure")
                }
            }
    }
    
    
    /* 휴대전화로 찾기 - 인증번호 */
    func certificationNumberByPhone(_ parameters: ByPhoneInput, viewController: FindIDByPhoneVC) {
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
                    // 이름, 아이디, 휴대전화 번호을 잘못 작성한 경우, 해당 로직을 실행한다.
                    print("DEBUG: faild connection \(error.localizedDescription)")
                }
            }
    }

    
}











