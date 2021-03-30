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
    func certificationNumberByPhone(_ parameters: ByPhoneInput, viewController: UIViewController) {
        let data = parameters
        let param: Parameters = [
            "receiver_type": "cellphone",
            "receiver": "01047850519",
            "name": "woosung"
        ]
        
        let header: HTTPHeaders = [ "Content-Type":"application/json"]
        
        // 입력 정보 .PUT
        AF.request("https://api.gongmanse.com/v1/recovery", method: .put, parameters: param, encoding: JSONEncoding.default, headers: nil)
//            .responseJSON{ response in
//                switch response.result {
//                case .success:
//                    let data = response.value
//                    print("DEBUG: \(data)")
//                    print("DEBUG: \(response)")
//                case .failure:
//                    print("DEBUG: \(response)")
//                }
//            }
        
            .responseDecodable(of: ByPhoneResponse.self) { response in
                switch response.result {
                case .success(let response):
                    print("DEBUG: \(response.key)")

                case .failure(let error):
                    print("DEBUG: faild connection \(error.localizedDescription)")
                }

            }
    }
    
    
    
    
    // TODO: response 이 서버로그와 함께 넘어오는 문제때문에 안드로이드에서도 구현을 미룬 상태, 추후에 변경되면 다시 작업할 예정. 03.30
    /* 이메일로 찾기 - 인증번호 */
    
    func certificationNumberByEmail(_ parameters: ByEmailInput, viewController: FindIDByEmailVC) {
        // Controller에서 이메일 및 유저정보를 받아온다.
        let data = ByEmailInput(receiver_type: "email", receiver: "gahyunlee1119@gmail.com", name: "이가현")
        
        let param: Parameters = [
            "receiver_type": "email",
            "receiver": "gahyunlee1119@gmail.com",
            "name": "이가현"
        ]
        
        // 입력 정보 .PUT
        /*
         구성방식)
         1. 데이터를 put으로 전송한다.
         2. response를 가져온다.
         3. 가져온 response 중에서  "로 시작하는 곳 부터 } 로 끝나는 곳까지 string을 슬라이싱한다.
         4. 그 값과 유저가 받은 인증번호를 비교하여 일치여부를 확인한다,
         */
        AF.request("https://api.gongmanse.com/v1/recovery", method: .put, parameters: param, encoding: URLEncoding.httpBody, headers: nil, interceptor: nil, requestModifier: nil)
            .responseData { response in
                switch response.result {
                case .success:
                    let text = response.debugDescription
                    let regEx = "[0-9]{6}"

                    let start = text.index(text.endIndex, offsetBy: -41)
                    let end = text.index(text.endIndex, offsetBy: -25)
                    let range = start..<end
                    
                    let findIndex = text.firstIndex(of: "\"")!
                    let lastIndex = text.lastIndex(of: "}")!
                    print("DEBUG: \(text.debugDescription.substring(with: range))")
                    print("DEBUG: \(text[findIndex..<lastIndex])")
                    let test = text[findIndex..<lastIndex]
                    print("DEBUG: \(test)")
                    
                    
                    
                    // 정규표현식을 통해서 {"key":숫자6자리} 만 필터링해보자.
                    
                case let . failure(error):
                    print("DEBUG: failure")
                }
            }
    }
    
}





