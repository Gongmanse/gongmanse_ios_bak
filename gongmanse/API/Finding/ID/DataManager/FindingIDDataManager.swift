//
//  FindingIDDataManager.swift
//  gongmanse
//
//  Created by 김우성 on 2021/03/29.
//  https://api.gongmanse.com/v1/recovery

import Foundation
import Alamofire

class FindingIDDataManager {
    let CODE_00 = "00"// 존재하지 않는 사용자
    let CODE_01 = "01"// 존재하는 사용자
    let CODE_10 = "10"// 존재하지만 아이디 일치하지 않음
    let CODE_11 = "11"// 존재하면서 아이디 일치
    
    
    /* 휴대전화로 찾기 - 인증번호 */
//    func certificationNumberByPhone(_ parameters: ByPhoneInput, viewController: FindIDByPhoneVC) {
//        // viewModel -> paramters 를 통해 값을 전달
//        let data = parameters
//
//        // Input Data Type
//        let param: Parameters = [
//            "receiver_type": "cellphone",
//            "receiver": "\(data.receiver)",
//            "name": "\(data.name)"
//        ]
//
//        // 입력 정보 .PUT
//        AF.request("\(Constant.BASE_URL)/v1/recovery", method: .put, parameters: param, encoding: JSONEncoding.default, headers: nil)
//            .responseDecodable(of: ByPhoneResponse.self) { response in
//                switch response.result {
//                case .success(let response):
//                    viewController.didSucceedCertificationNumber(response: response)
//
//                case .failure(let error):
//
//                    print("DEBUG: faild connection \(error.localizedDescription)")
//                }
//            }
//    }
    
    
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
        let urlString = "\(apiBaseURL)/v/member/recoverid?receiver_type=email&receiver=\(data.receiver)&name=\(data.name)"
        if let encoded = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),let url = URL(string: encoded)
         {
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
    }
    
    
    // TODO: response 이 서버로그와 함께 넘어오는 문제때문에 안드로이드에서도 구현을 미룬 상태, 추후에 변경되면 다시 작업할 예정. 03.30
    /* 이메일로 찾기 - 인증번호 */
    
//    func certificationNumberByEmail(_ parameters: ByEmailInput, viewController: FindIDByEmailVC) {
//        // 이메일 및 유저정보를 받아온다.
//        let data = ByEmailInput(receiver_type: "email", receiver: "gahyunlee1119@gmail.com", name: "이가현") // parameters
//
//        let param: Parameters = [
//            "receiver_type": "email",
//            "receiver": "\(parameters.receiver)",
//            "name": "\(parameters.name)"
//        ]
//
//        // 입력 정보 .PUT
//        /*
//         구성방식)
//         1. 데이터를 put으로 전송한다.
//         2. response를 가져온다.
//         3. 가져온 response 중에서  "로 시작하는 곳 부터 } 로 끝나는 곳까지 string을 슬라이싱한다.
//         4. 그 값과 유저가 받은 인증번호를 비교하여 일치여부를 확인한다,
//         */
//        AF.request("\(Constant.BASE_URL)/v1/recovery", method: .put, parameters: param, encoding: URLEncoding.httpBody, headers: nil, interceptor: nil, requestModifier: nil)
//            .responseData { response in
//                switch response.result {
//                case .success:
//                    let text = response.debugDescription            // 서버 로그까지 포함된 데이터
//                    viewController.didSucceed(response: text)
//                case .failure:
//                    print("DEBUG: failure")
//                }
//            }
//    }
    
    
    //MARK: - 회원 가입정보 조회  21.12.08
    func findRegister(type: String, _ params: Parameters, viewController: UIViewController) {
        var name: String = ""
        var receiver: String = ""
        var urlString = "\(apiBaseURL)/v/member/check_member?"
        for param in params {
            urlString.append("\(param.key)=\(param.value)&")
            if param.key == "name" {
                name = param.value as! String
            } else {
                receiver = param.value as! String
            }
        }
        
        if let encoded = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: encoded)
         {
            AF.request(url)
                .responseDecodable(of: CheckMember.self) { response in
                    switch response.result {
                    case .success(let response):
                        print("response : \(response))")
                        if response.data == self.CODE_00 {
                            viewController.presentAlert(message: "존재하지 않는 사용자입니다.", alignment: .center)
                        } else if response.data == self.CODE_01 {
                            self.certificationNumber(receiver_type: type, name: name, receiver: receiver, vc: viewController)
                        }
                        
                    case .failure:
                        print("DEBUG: failure")
                    }
                }
        }
    }
    
    //MARK: - 인증번호 요청 통합  21.12.08
    func certificationNumber(receiver_type: String, name: String, receiver: String ,vc: UIViewController) {
        let param: Parameters = [
            "receiver_type": receiver_type,
            "receiver": receiver,
            "name": name
        ]
        
        // 입력 정보 .PUT
        AF.request("\(Constant.BASE_URL)/v1/recovery", method: .put, parameters: param, encoding: JSONEncoding.default, headers: nil)
//            .responseDecodable(of: AuthNumResponse.self)
            .response()
            { response in
                switch response.result {
                case .success:
                    if receiver_type == "email" {
                        (vc as! FindIDByEmailVC)
                            .didSucceed(response: "\(String(decoding: response.data!, as: UTF8.self))")
                    } else if receiver_type == "cellphone" {
                        let decoder = JSONDecoder()
                        if let json = try? decoder.decode(AuthNumResponse.self, from: response.data!) {
                            (vc as! FindIDByPhoneVC)
                                .didSucceedCertificationNumber(response: json)
                        }
                    }
                case .failure(let error):
                    
                    print("DEBUG: faild connection \(error.localizedDescription)")
                }
            }
    }
}





