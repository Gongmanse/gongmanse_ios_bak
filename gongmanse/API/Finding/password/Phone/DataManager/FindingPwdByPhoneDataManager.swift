/*
 * FindingPwdByPhoneDataManager.swift
 * gongmanse

 * Created by 김우성 on 2021/04/01.

 [FindingPwdByPhoneVC 에서 사용되는 Alamofire 메소드 구현]
 * 1. 사용자가 UITextField에 작성한 ID와 UITextField에 작성한 이름 휴대전화 정보가 일치한지 확인한다.
 *  - "findingIDResultByPhone()" 메소드를 호출하여 사용자가 작성한 이름과 휴대전화를 바탕으로 아이디 값을 가져온다.
 *     만약 불일치 한다면, 더이상 진행하지 않는다.
 * 2. 일치한다면 "certificationNumberByPhone()" 메소드를 호출하여 인증번호를 요청한다.
 *  - API에서 수신한 인증번호와 유저가 입력한 인증번호가 일치한다면, 새 비밀번호 등록 페이지로 이동한다.
 *
 * cf) 비밀번호 찾기이지만 사실상 이름과 휴대전화만 있다면 아이디와 비밀번호를 모두 찾을 수 있는 구조
 * (보통의 서비스 경우, API에서 true false만 response로 넘겨주나, 공만세 측에서 이 방법밖에 사용할 수 없다고 하여 이렇게 구현함)
 */


import Foundation
import Alamofire

class FindingPwdByPhoneDataManager {
    let CODE_00 = "00"// 존재하지 않는 사용자
    let CODE_01 = "01"// 존재하는 사용자
    let CODE_10 = "10"// 존재하지만 아이디 일치하지 않음
    let CODE_11 = "11"// 존재하면서 아이디 일치
    
    /* 휴대전화로 찾기 - 인증번호 */
    /// "비밀번호찾기 > 휴대전화" 페이지에서 인증번호를 받기 위한  API 메소드
//    func certificationNumberByPhone(_ parameters: ByPhoneInput, viewController: FindingPwdByPhoneVC) {
//
//        // viewModel -> paramters 를 통해 값을 전달
//        /// Textfield에서 입력받은 값을 저장한 프로퍼티
//        let data = parameters
//
//        let cellphone = "cellphone"
//
//        /// 서버에 Body에 넣을 parameter 데이터
//        let param: Parameters = [
//            "receiver_type": "\(cellphone)",
//            "receiver": "\(data.receiver)",
//            "name": "\(data.name)"
//        ]
//
//        /// Alamofire 메소드를 활용한 API Request
//        AF.request("\(Constant.BASE_URL)/v1/recovery", method: .put, parameters: param, encoding: JSONEncoding.default, headers: nil)
//            .responseDecodable(of: ByPhoneResponse.self) { response in
//
//                /// Request 결과에 따른 Response switch문
//                /// - `.success` : Response 결과 전부를 넘겨준다.(FindingPwdByPhoneVC에)
//                /// - `.failure` : 에러에 대한 메세지를 넘겨준다.
//                switch response.result {
//                case .success(let response):
//                    viewController.didSucceedCertificationNumber(response: response)
//
//                case .failure(let error):
//                    viewController.didFaildSendingCertificationNumber()
//                    print("DEBUG: faild connection \(error.localizedDescription)")
//                }
//            }
//    }
    
    /* 아이디 찾기 결과 - 휴대전화로 찾기 */
    /// 비밀번호 찾기 > 휴대전화로 찾기 로직에서 사용자가 입력한 ID와 비밀번호 찾기 요청한 ID가 일치한 지
    ///  확인하기 위해 호출하는 ID 찾기 API메소드
    func findingIDResultByPhone(_ parameters: FindingIDResultInput, viewController: FindingPwdByPhoneVC) {
        
        /// Textfield에서 입력받은 값(이름과 휴대전화번호)을 저장한 프로퍼티
        let data = parameters
        
        /// URL에 한글이 포함 될 시, 서버에서 전달되지 않는 문제를 해결하기 위해 .addingPerecentEncoding
        /// 처리하여 인스턴스를 저장할 프로퍼티
        let url = "\(Constant.BASE_URL)/v/member/recoverid?receiver_type=cellphone&receiver=\(data.receiver)&name=\(data.name)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        /// Alamofire 메소드를 활용한 API Request
        AF.request(url).responseDecodable(of: FindingPwdByPhoneResponse.self) { response in
            
            /// Request 결과에 따른 Response switch문
            /// - `.success` : Response 결과 전부를 넘겨준다.(FindingPwdByPhoneVC에)
            /// - `.failure` : 에러에 대한 메세지를 넘겨준다.
            switch response.result {
            case .success(let response):
                viewController.didSucceedSendingID(response: response)
            case .failure(let error):
                viewController.didFaildSendingCertificationNumber()
                print("DEBUG: faild connection \(error.localizedDescription)")
            }
        }
    }
    
    
    //MARK: - 회원 가입정보 조회  21.12.08
//    func findRegister(_ params: Parameters, viewController: UIViewController) {
//        var name: String = ""
//        var receiver: String = ""
//        var urlString = "\(apiBaseURL)/v/member/check_member?"
//        for param in params {
//            urlString.append("\(param.key)=\(param.value)&")
//            if param.key == "name" {
//                name = param.value as! String
//            } else if param.key == "phone" {
//                receiver = param.value as! String
//            }
//        }
//
//        if let encoded = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: encoded)
//         {
//            AF.request(url)
//                .responseDecodable(of: CheckMember.self) { response in
//                    switch response.result {
//                    case .success(let response):
//                        print("response : \(response))")
//                        if response.data == self.CODE_00 {
//                            viewController.presentAlert(message: "존재하지 않는 사용자입니다.", alignment: .center)
//                        } else if response.data == self.CODE_10 {
//                            viewController.presentAlert(message: "아이디가 일치하지 않습니다.", alignment: .center)
//                        } else if response.data == self.CODE_11 {
//                            self.certificationNumber(name: name, receiver: receiver, vc: viewController)
//                        }
//
//                    case .failure:
//                        print("DEBUG: failure")
//                    }
//                }
//        }
//    }
    
    //MARK: - 인증번호 요청 21.12.08
    func certificationNumber(name: String, receiver: String ,vc: UIViewController) {
        let param: Parameters = [
            "receiver_type": "cellphone",
            "receiver": receiver,
            "name": name
        ]
        
        // 입력 정보 .PUT
        AF.request("\(Constant.BASE_URL)/v1/recovery", method: .put, parameters: param, encoding: JSONEncoding.default, headers: nil)
            .responseDecodable(of: AuthNumResponse.self) { response in
                switch response.result {
                case .success(let response):
                    print("response : \(response)")
                    (vc as! FindingPwdByPhoneVC)
                            .didSucceedCertificationNumber(response: response)
                    
                case .failure(let error):
                    
                    print("DEBUG: faild connection \(error.localizedDescription)")
                }
            }
    }
}











