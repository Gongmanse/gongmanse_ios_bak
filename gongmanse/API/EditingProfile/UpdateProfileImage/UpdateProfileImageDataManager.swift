//
//  UpdateProfileImageDataManager.swift
//  gongmanse
//
//  Created by 김우성 on 2021/06/02.
//

import Foundation
import UIKit
import Alamofire

class UpdateProfileImageDataManager {
    
    /* 프로필이미지 변경 */
    func changeProfileImage(_ parameters: UpdateProfileImageInput, viewController: EditingProfileController) {
        
        let url = "https://file.gongmanse.com/transfer/profiles/image_upload"
        let data = parameters
        
        let profileImage = parameters.file
        
        
        
        // 로그인정보 post
        AF.upload(multipartFormData: { MultipartFormData in
            MultipartFormData.append(profileImage, withName: "file", fileName: "profileImage.png", mimeType: "image/png")
            MultipartFormData.append("\(data.token)".data(using: .utf8)!, withName: "token")   // 토큰
            
        }, to: url)
        
        // Result를 Response 타입에 맞게 변환
        .responseDecodable(of: UpdateProfileImageResponse.self) { response in
            switch response.result {
            case .success(let response):
                print("DEBUG: 이미지변경 성공")
                viewController.didSuccessUpdateProfileImage(response: response)
                
            case .failure(let error):
                // 연결 실패
                print("DEBUG: failed connection \(error.localizedDescription)")
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
//    /// 비밀번호 변경 API메소드
//    func changePassword(_ parameters: NewPasswordInput, viewController: EditingProfileController) {
//        
//        let data = parameters
//        
//        // 받은 데이터를 AF를 통한 업로드
//        AF.upload(multipartFormData: { MultipartFormData in
//            MultipartFormData.append(Data("\(data.username)".utf8), withName: "username")
//            MultipartFormData.append(Data("\(data.password)".utf8), withName: "password")
//        }, to: "\(Constant.BASE_URL)/v/member/updatepw")
//        
//        // Result를 Response 타입에 맞게 변환
//        .responseDecodable(of: NewPasswordResponse.self) { response in
//            
//            switch response.result {
//            case .success(let response):
//                // 연결 성공
//                if response.code == 200 {
//                    // 회원가입 성공 시, 성공메세지 전달
//                    print("DEBUG: 비밀번호변경 성공")
//                    
//                } else {
//                    // 화원가입 실패 시, 실패메세지 전달 (실패한 항목이 많으면 그만큼 메세지 항목이 많아짐)
//                    print("DEBUG: falid changing Password")
//                }
//                
//            case .failure(let error):
//                // 연결 실패
//                print("DEBUG: failed connection \(error.localizedDescription)")
//            }
//        }
//    }
//    
    func changeNicknameAndEmail(_ parameters: changeNicknameAndEmailInput, viewController: EditingProfileController) {
        
        let url = "https://api.gongmanse.com/v/member/getuserinfo"
        let param: Parameters =
            [
            "token"     : parameters.token,
            "nickname"  : parameters.nickname,
            "email"     : parameters.email
            ]
        
        // PATCH
        AF.request(url,
                   method: .patch,
                   parameters: param,
                   encoding: URLEncoding.httpBody,
                   headers: nil,
                   interceptor: nil,
                   requestModifier: nil)
            
            // API에서 성공했을 시, 아무 응답이 없고 실패했을 시 DB Error Log를 호출한다.
            // 그러므로 Response에 대한 Decoding 전략은 작성하지 않았다. (정확히 말하면 필요가 없음)
            .responseString { response in
                print("DEBUG: 프로필수정 API Response \(response)")
            }
    }
}

struct changeNicknameAndEmailInput: Encodable {
    
    var token: String
    var nickname: String
    var email: String
}
