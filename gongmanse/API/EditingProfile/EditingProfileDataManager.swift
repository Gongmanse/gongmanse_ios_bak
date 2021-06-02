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
    

}
