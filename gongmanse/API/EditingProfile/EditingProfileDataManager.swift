//
//  EditingProfileDataManager.swift
//  gongmanse
//
//  Created by 김우성 on 2021/06/01.
//

import Alamofire
import UIKit

class EditingProfileDataManager {
    func getProfileInfoFromAPI(_ parameters: EditingProfileInput, viewController: EditingProfileController) {
        
        let data = parameters
        let url = "https://api.gongmanse.com/v/member/getuserinfo?token=\(data.token)"
        
        /// HTTP Method: GET
        /// API 명: "01010. 프로필 정보 조회"
        AF.request(url)
            .responseDecodable(of: EditingProfileResponse.self) { response in
                
                switch response.result {
                case .success(let response):
                    viewController.didSuccessNetworing(response: response)
                    
                case .failure(let error):
                    print("DEBUG: 영상 API 통신 실패")
                    print("DEBUG: faild connection \(error.localizedDescription)")
                }
            }
    }
    
    /// 비밀번호 변경 API메소드
    /// - json으로 송신 시, 정상적으로 비밀번호가 변경되지 않음
    /// - formdata로 메소드 구성 시, 정상적으로 비밀번호가 변경됨
    func changePassword(_ parameters: ChangePasswordInput, viewController: EditingProfileController) {
        // Controller에서 데이터 수신
        let data = parameters
        
        // 받은 데이터를 AF를 통한 업로드
        AF.upload(multipartFormData: { MultipartFormData in
            MultipartFormData.append(Data("\(data.username)".utf8), withName: "username")
            MultipartFormData.append(Data("\(data.password)".utf8), withName: "password")
        }, to: "\(Constant.BASE_URL)/v/member/updatepw")
        
        // Result를 Response 타입에 맞게 변환
        .responseDecodable(of: ChangePasswordResponse.self) { response in
            
            switch response.result {
            case .success(let response):
                // 연결 성공
                if response.code == 200 {
                    // 회원가입 성공 시, 성공메세지 전달
                    print("DEBUG: \(#function) 성공")
                    
                    
                } else {
                    // 화원가입 실패 시, 실패메세지 전달 (실패한 항목이 많으면 그만큼 메세지 항목이 많아짐)
                    print("DEBUG: falid changing Password")
                }
                
            case .failure(let error):
                // 연결 실패
                print("DEBUG: failed connection \(error.localizedDescription)")
            }
        }
    }
}
