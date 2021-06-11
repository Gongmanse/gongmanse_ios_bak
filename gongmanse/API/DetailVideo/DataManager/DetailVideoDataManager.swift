//
//  DetailVideoDataManager.swift
//  gongmanse
//
//  Created by 김우성 on 2021/04/26.
//

import Foundation
import Alamofire

/// 상세화면 - 동영상
/// - 동영상관련 API를 처리하는 클래스
class DetailVideoDataManager {
    
    /// 상세화면에서 호출할 DataManager
    /// - 동영상 링크: 동영상 재생을 위한 URL을 받아온다.
    /// - 자막 링크: .vtt 확장자로 URL을 받아온다.
    /// - 태그 String: sTags 라는 항목으로 받아온다.
    func DetailScreenDataManager(_ parameters: DetailVideoInput, viewController: DetailScreenController) {
        
        // viewModel -> paramters 를 통해 값을 전달한다.
        let data = parameters
        
        // URL을 구성한다.
        
        let url = Constant.BASE_URL + "/v/video/details?video_id=\(data.video_id)&token=\(data.token)"
        
        /// HTTP Method: GET
        /// API 명: "02008. 동영상 상세 정보"
        AF.request(url)
            .responseDecodable(of: DetailVideoResponse.self) { response in
                
                switch response.result {
                case .success(let response):
                    print("DEBUG: 영상 API 통신 성공")
//                    print("DEBUG: 통신한 데이텨 결과 \(response.data)")
                    viewController.didSucceedNetworking(response: response)
                    
                case .failure(let error):
                    print("DEBUG: 영상 API 통신 실패")
                    print("DEBUG: faild connection \(error.localizedDescription)")
                }
            }
    }
    
    func apiPassRatingDataToRatingVC(_ parameters: DetailVideoInput, viewController: RatingController) {
        
        // viewModel -> paramters 를 통해 값을 전달한다.
        let data = parameters
        
        // URL을 구성한다.
        
        let url = Constant.BASE_URL + "/v/video/details?video_id=\(data.video_id)&token=\(data.token)"
        
        /// HTTP Method: GET
        /// API 명: "02008. 동영상 상세 정보"
        AF.request(url)
            .responseDecodable(of: DetailVideoResponse.self) { response in
                
                switch response.result {
                case .success(let response):
                    print("DEBUG: 영상 API 통신 성공")
//                    print("DEBUG: 통신한 데이텨 결과 \(response.data)")
                    viewController.didSuccessNetworking(response: response)
                    
                case .failure(let error):
                    print("DEBUG: 영상 API 통신 실패")
                    print("DEBUG: faild connection \(error.localizedDescription)")
                }
            }
    }
    
    
//    func fullScreenVideoDataManager(_ parameters: DetailVideoInput, viewController: VideoFullScreenController) {
//
//        // viewModel -> paramters 를 통해 값을 전달한다.
//        let data = parameters
//
//        // URL을 구성한다.
////        let url = Constant.BASE_URL + "/v/video/details?video_id=\(data.video_id)&token=\(data.token)"
//
//        let url = Constant.BASE_URL + "/v/video/details?video_id=\(data.video_id)&token=\(data.token)"
//
//        /// HTTP Method: GET
//        /// API 명: "02008. 동영상 상세 정보"
//        AF.request(url)
//            .responseDecodable(of: DetailVideoResponse.self) { response in
//
//                switch response.result {
//                case .success(let response):
//                    print("DEBUG: 영상 API 통신 성공")
//                    print("DEBUG: 통신한 데이텨 결과 \(response.data)")
//                    viewController.didSucceedNetworking(response: response)
//
//                case .failure(let error):
//                    print("DEBUG: 영상 API 통신 실패")
//                    print("DEBUG: faild connection \(error.localizedDescription)")
//                }
//            }
//    }
    
    
    
    
    /// 상세화면에서 호출할 DataManager
    /// - 동영상 링크: 동영상 재생을 위한 URL을 받아온다.
    /// - 자막 링크: .vtt 확장자로 URL을 받아온다.
    /// - 태그 String: sTags 라는 항목으로 받아온다.
    func DetailVideoDataManager(_ parameters: DetailVideoInput, viewController: VideoController) {
        
        // viewModel -> paramters 를 통해 값을 전달한다.
        let data = parameters
        
        // URL을 구성한다.
//        let url = Constant.BASE_URL + "/v/video/details?video_id=\(data.video_id)&token=\(data.token)"
        
        let url = Constant.BASE_URL + "/v/video/details?video_id=\(data.video_id)&token=\(data.token)"
        
        /// HTTP Method: GET
        /// API 명: "02008. 동영상 상세 정보"
        AF.request(url)
            .responseDecodable(of: DetailVideoResponse.self) { response in
                
                switch response.result {
                case .success(let response):
                    print("DEBUG: 영상 API 통신 성공")
                    print("DEBUG: 통신한 데이텨 결과 \(response.data)")
//                    viewController.didSucceedNetworking(response: response)
                    viewController.didSuccessReceiveVideoData(response: response)
                case .failure(let error):
                    print("DEBUG: 영상 API 통신 실패")
                    print("DEBUG: faild connection \(error.localizedDescription)")
                    viewController.failToConnectVideoByTicket()
                }
            }
    }
    
    
    func fullScreenVideoDataManager(_ parameters: DetailVideoInput, viewController: VideoFullScreenController) {
        
        // viewModel -> paramters 를 통해 값을 전달한다.
        let data = parameters
        
        // URL을 구성한다.
//        let url = Constant.BASE_URL + "/v/video/details?video_id=\(data.video_id)&token=\(data.token)"
        
        let url = Constant.BASE_URL + "/v/video/details?video_id=\(data.video_id)&token=\(data.token)"
        
        /// HTTP Method: GET
        /// API 명: "02008. 동영상 상세 정보"
        AF.request(url)
            .responseDecodable(of: DetailVideoResponse.self) { response in
                
                switch response.result {
                case .success(let response):
                    print("DEBUG: 영상 API 통신 성공")
                    print("DEBUG: 통신한 데이텨 결과 \(response.data)")
                    viewController.didSucceedNetworking(response: response)
                    
                case .failure(let error):
                    print("DEBUG: 영상 API 통신 실패")
                    print("DEBUG: faild connection \(error.localizedDescription)")
                }
            }
    }
}


