//
//  FindingIDDataManager.swift
//  gongmanse
//
//  Created by 김우성 on 2021/03/29.
//  https://api.gongmanse.com/v1/recovery

import Foundation
import Alamofire

class FindingIDDataManager {
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
                    print("DEBUG: faild connection \(error.localizedDescription)")
                }
            }
    }
    
    
    /* 아이디 찾기 결과 - 휴대전화로 찾기 */
    func findingIDResultByPhone(_ parameters: FindingIDResultInput, viewController: FindIDResultVC) {
        // viewModel -> paramters 를 통해 값을 전달
        let data = parameters
        
        let url = "\(Constant.BASE_URL)/v/member/recoverid?receiver_type=cellphone&receiver=\(data.receiver)&name=\(data.name)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        // 휴대전화로 찾기
        AF.request(url)
                    .responseDecodable(of: FindingIDResultResponse.self) { response in
                        switch response.result {
                        case .success(let response):
                            viewController.didSucceedVaildation(response)
                        case .failure(let error):
                            print("DEBUG: faild connection \(error.localizedDescription)")
                        }
                    }
    }
    
    
    /* 아이디 찾기 결과 - 이메일로 찾기 */
    func findingIDResultByEmail(_ parameters: FindingIDResultInput, viewController: FindIDResultVC) {
        // viewModel -> paramters 를 통해 값을 전달
        let data = parameters
        
        // 이메일로 찾기
        let urlString = "https://api.gongmanse.com/v/member/recoverid?receiver_type=email&receiver=\(data.receiver)&name=\(data.name)"
        if let encoded = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),let url = URL(string: encoded)
         {
             AF.request(url)
//                .responseJSON { (json) in
//                 print(json)
//                 //Enter your code here
//             }
                .responseDecodable(of: FindingIDResultResponse.self) { response in
                    switch response.result {
                    case .success(let response):
                        viewController.didSucceedVaildation(response)
                    case .failure(let error):
                        print("DEBUG: faild connection \(error.localizedDescription)")
                    }
                }
        }
    }
    
    
    // TODO: response 이 서버로그와 함께 넘어오는 문제때문에 안드로이드에서도 구현을 미룬 상태, 추후에 변경되면 다시 작업할 예정. 03.30
    /* 이메일로 찾기 - 인증번호 */
    
    func certificationNumberByEmail(_ parameters: ByEmailInput, viewController: FindIDByEmailVC) {
        // 이메일 및 유저정보를 받아온다.
        let data = ByEmailInput(receiver_type: "email", receiver: "gahyunlee1119@gmail.com", name: "이가현") // parameters
        
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
                    viewController.didSucceed(response: text)
                case .failure:
                    print("DEBUG: failure")
                }
            }
    }
    
    
    
    
    

    
    
}





