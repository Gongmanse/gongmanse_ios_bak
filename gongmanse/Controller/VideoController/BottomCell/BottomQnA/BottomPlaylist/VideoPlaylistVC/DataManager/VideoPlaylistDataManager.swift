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
        let url = apiBaseURL + "/v/video/serieslist?series_id=\(data.seriesID)&offset=0"
        
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
}
