//
//  VideoPlaylistDataManager.swift
//  gongmanse
//
//  Created by 김우성 on 2021/06/16.
//

import Foundation
import Alamofire

class VideoPlaylistDataManager {
    
    func getVideoPlaylistDataFromAPI(_ parameters: VideoPlaylistInput, viewController: VideoPlaylistVC) {
        
        // viewModel -> paramters 를 통해 값을 전달한다.
        let data = parameters
        
        // URL을 구성한다.
        let url = apiBaseURL + "/v/video/serieslist?series_id=\(data.seriesID)&offset=\(data.offset)"
        
        /// HTTP Method: GET
        AF.request(url)
            .responseDecodable(of: VideoPlaylistResponse.self) { response in
                
                switch response.result {
                case .success(let response):
                    viewController.didSuccessGetPlaylistData(response)
                    
                case .failure(let error):
                    print("DEBUG: 재생목록 API 통신 실패")
                    print("DEBUG: faild connection \(error.localizedDescription)")
                }
            }
    }
    
    func addVideolistInAutoplaying(baseURL: String,
                                   _ viewController: VideoPlaylistVC) {
        
        // viewModel -> paramters 를 통해 값을 전달한다.
//        let data = parameters
        let autoplayDM = AutoplayDataManager.shared

        // dummy data
        let sortedId = 3
        let selectedItem = 0

        autoplayDM.mainSubjectListCount += 20
        
        
        // URL을 구성한다.
        guard let url = URL(string: baseURL + "offset=\(autoplayDM.mainSubjectListCount)&limit=20&sortId=\(sortedId ?? 3)&type=\(selectedItem ?? 0)") else { return }
        
        /// HTTP Method: GET
        AF.request(url)
            .responseDecodable(of: VideoInput.self) { response in
                
                switch response.result {
                case .success(let response):
                    print("DEBUG: 무한스크롤 API 성공")
                    viewController.didSuccessAddVideolistInAutoplaying(response)
                    
                case .failure(let error):
                    print("DEBUG: 재생목록 API 통신 실패")
                    print("DEBUG: faild connection \(error.localizedDescription)")
                }
            }
    }
    
    func getVideoPlaylistDataFromAPIInNote(_ parameters: VideoPlaylistInput, viewController: LessonNoteViewModel) {
        
        // viewModel -> paramters 를 통해 값을 전달한다.
        let data = parameters
        
        // URL을 구성한다.
        let url = apiBaseURL + "/v/video/serieslist?series_id=\(data.seriesID)&offset=\(data.offset)"
//        let url = "https://api.gongmanse.com/v/video/serieslist?series_id=643&offset=20"
        
        /// HTTP Method: GET
        AF.request(url)
            .responseDecodable(of: VideoPlaylistResponse.self) { response in
                
                switch response.result {
                case .success(let response):
                    viewController.didSuccessAPI(response: response)
                    print("DEBUG: 시리즈해당 VideoID가져오기 성공")
                    
                case .failure(let error):
                    print("DEBUG: 시리즈해당 VideoID가져오기 실패")
                    print("DEBUG: faild connection \(error.localizedDescription)")
                }
            }
    }
}
