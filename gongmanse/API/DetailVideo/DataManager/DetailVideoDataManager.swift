//
//  DetailVideoDataManager.swift
//  gongmanse
//
//  Created by 김우성 on 2021/04/26.
//

import Foundation
import Alamofire


class DetailVideoDataManager {
    
    /* 상세화면 동영상 */
    func DetailVideoDataManager(_ parameters: DetailVideoInput, viewController: VideoController) {
        // viewModel -> paramters 를 통해 값을 전달
        let data = parameters
        
        print("DEBUG: 입력받은 비디오ID는 \"\(data.video_id)\" 입니다.")
        print("DEBUG: 입력받은 토큰은 \"\(data.token)\" 입니다.")
        
//        let url = Constant.BASE_URL + "/v/video/details?video_id=\(data.video_id)&token=\(data.token)"
        let url = "\(Constant.BASE_URL)/v/video/details?video_id=11375&token=NGFkMWQ3ZWZkNTE2NzQ5ZjI3YjU3Y2Y1ZWFlN2IyM2IxM2E2MGI2ZjExNTNkNzc3ZTkxZDVmMzEwY2MwMTUzOWQ5YWM1N2M5MjJhYzYxYTc2NDIzNGUxNGNlOTNiOTQ0ODQ0ZjNmNTFhZGY2ZGU5NmJiNDAwZmJiODdmN2VjYTNrN3M2Sk0rb2Zrd3ZQMTRKbUtRNk43ZTdhMzhhTjU2UExSM3lWYTloM3UzSnhVZnFmRDFiT1BGb25Ha1Y3YnhnTXQrbzFHOGtZZXJxNGRpWEZuUCttUT09"
        
        print("DEBUG: URL은 \(url) 입니다.")
        
        // 휴대전화로 찾기
        AF.request(url)
            .responseDecodable(of: DetailVideoResponse.self) { response in
                
                switch response.result {
                case .success(let response):
                    print("DEBUG: 영상 API 통신 성공")
                    print("DEBUG: 통신한 데이텨 결과 \(response.data)")
                    viewController.didSucceedNetworking()
                    
                case .failure(let error):
                    print("DEBUG: 영상 API 통신 실패")
                    print("DEBUG: faild connection \(error.localizedDescription)")
                }
            }
    }
}


