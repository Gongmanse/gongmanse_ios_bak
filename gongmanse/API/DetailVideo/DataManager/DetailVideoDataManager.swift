//
//  DetailVideoDataManager.swift
//  gongmanse
//
//  Created by 김우성 on 2021/04/26.
//

import Foundation
import Alamofire

/* 아이디 찾기 결과 - 휴대전화로 찾기 */
func DetailVideoDataManager(_ parameters: DetailVideoInput, viewController: VideoController) {
    // viewModel -> paramters 를 통해 값을 전달
    let data = parameters
    
    let url = "\(Constant.BASE_URL)/v/video/details?video_id=\(data.video_id)&token=\(data.token)"
    
    // 휴대전화로 찾기
    AF.request(url)
        .responseDecodable(of: DetailVideoResponse.self) { response in
            switch response.result {
            case .success(let response):
                print("DEBUG: 영상 API 통신 성공")
                print("DEBUG: 통신한 데이텨 결과 \(response.data)")
            case .failure(let error):
                print("DEBUG: 영상 API 통신 실패")
                print("DEBUG: faild connection \(error.localizedDescription)")
            }
        }
}
