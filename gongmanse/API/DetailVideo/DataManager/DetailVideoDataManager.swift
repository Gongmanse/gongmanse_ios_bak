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
        AF.request(url)
            .responseDecodable(of: DetailVideoResponse.self) { response in
                
                switch response.result {
                case .success(let response):
//                    print("DEBUG: 통신한 데이텨 결과 \(response.data)")
                    viewController.didSuccessNetworking(response: response)
                    
                case .failure(let error):
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
    
    
    func updateNeedRating(_ parameters: DetailVideoInput, viewController: VideoController) {
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
                    viewController.didSuccessUpdateRating(response: response)
                case .failure(let error):
                    print("DEBUG: 영상 API 통신 실패")
                    print("DEBUG: faild connection \(error.localizedDescription)")
                    viewController.failToConnectVideoByTicket()
                }
            }
    }
    
    /// 상세화면에서 호출할 DataManager
    /// - 동영상 링크: 동영상 재생을 위한 URL을 받아온다.
    /// - 자막 링크: .vtt 확장자로 URL을 받아온다.
    /// - 태그 String: sTags 라는 항목으로 받아온다.
    func DetailVideoDataManager(_ parameters: DetailVideoInput, viewController: VideoController, showIntro: Bool = true, refreshList: Bool = true,
                                fromPIP: Bool = false) {
        
        if showIntro {
            //초기 값 설정
            viewController.noteViewController?.view.removeFromSuperview()
            viewController.noteViewController?.removeFromParent()
            viewController.noteViewController = nil
            viewController.qnaCell?.removeFromSuperview()
            viewController.qnaCell = nil
            
            if refreshList {
                viewController.videoPlaylistVC?.view.removeFromSuperview()
                viewController.videoPlaylistVC?.removeFromParent()
                viewController.videoPlaylistVC = nil
                
                //노트보기 탭으로
                viewController.pageCurrentIndex = 0
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    viewController.customMenuBar.videoMenuBarTabBarCollectionView.selectItem(at: IndexPath(row: Int(viewController.pageCurrentIndex), section: 0), animated: true, scrollPosition: .centeredVertically)
                    viewController.customMenuBar.collectionView(viewController.customMenuBar.videoMenuBarTabBarCollectionView, didSelectItemAt: IndexPath(item: Int(viewController.pageCurrentIndex), section: 0))
                }
                //강의정보창 닫기
                if viewController.teacherInfoFoldConstraint!.isActive == false && !UIWindow.isLandscape {
                    viewController.teacherInfoFoldConstraint!.isActive = true
                    viewController.teacherInfoUnfoldConstraint!.isActive = false
                }
            }
            
            viewController.videoURL = NSURL(string: "")
            viewController.removePeriodicTimeObserver()
            viewController.setRemoveNotification()
            viewController.setNotification()
            
            if fromPIP { //인트로 스킵한다
                viewController.isStartVideo = true
                viewController.isEndVideo = false
            } else {
                viewController.isStartVideo = false
                viewController.isEndVideo = false
                viewController.playInOutroVideo(1)
                viewController.backButton.alpha = 1
            }
        }
        
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
    
    func DetailVideoDataManager(_ videoID: String, completion: @escaping (_ response: DetailVideoResponse) -> Void) {
        let token = Constant.token
        let url = Constant.BASE_URL + "/v/video/details?video_id=\(videoID)&token=\(token)"
        
        /// HTTP Method: GET
        AF.request(url)
            .responseDecodable(of: DetailVideoResponse.self) { response in
                
                switch response.result {
                case .success(let response):
                    print("DetailVideoDataManager : \(response.data)")
                    completion(response)
                case .failure(let error):
                    print("DetailVideoDataManager : faild connection \(error.localizedDescription)")
                }
            }
    }
}


