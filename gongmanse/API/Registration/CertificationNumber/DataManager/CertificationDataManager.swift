//
//  CertificationDataManager.swift
//  gongmanse
//
//  Created by 김우성 on 2021/03/23.
//
//  https://api.gongmanse.com/v1/sms/verifications


import Alamofire

class CertificationDataManager {
    func sendingNumber(_ parameters: CertificationNumberInput, viewController: CheckUserIdentificationVC) {
        // Controller에서 휴대전화번호 데이터 받음
        let data = viewController.userInfoData.phone_number

        let number = [0,1,0,4,7,8,5,0,5,1,9]


        // 휴대전화번호를 post
        AF.upload(multipartFormData: { MultipartFormData in
            4

            #warning("Int -> Data 로 변환하는 것 먼저하자. 관련 문서좀 찾아보야할 듯. 아니면 이걸 어떻게 넘기지??")
            MultipartFormData.append("\(parameters.phone_number)".data(using: .utf8)!, withName: "phone_number")

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
}


//class CertificationDataManagers {
//    func sendingNumber(_ parameters: CertificationNumberInput, viewController: CheckUserIdentificationVC) {
//        AF.request("\(Constant.BASE_URL)/v1/sms/verifications", method: .post, parameters: parameters.phone_number, encoder: JSONParameterEncoder(), headers: nil)
//            .responseDecodable(of: CertificationNumberResponses.self) { response in
//                switch response.result {
//                case .success(let response):
//                    if response.message == "ok" {
//                        viewController.didSendingNumber(response: response)
//                    } else {
//                        print("DEBUG: 실패")
//                        print("DEBUG: \(response.message)")
//                    }
//                case .failure(let error):
//                    print(error.localizedDescription)
//
//                }
//            }
//    }
//}
