//
//  VideoQnAAPIManager.swift
//  gongmanse
//
//  Created by wallter on 2021/05/14.
//

import Foundation
import Alamofire

struct VideoQnAAPIManager {
    
    func fetchVideoQnAApi(_ videoId: String, _ token: String, completion: @escaping resultModel<VideoQnAModel>) {
        
        let videoUrl = "\(apiBaseURL)/v/video/detail_qna?video_id=\(videoId)&token=\(token)"
        
        AF.request(videoUrl, method: .get)
            .responseDecodable(of: VideoQnAModel.self) { response in
                switch response.result {
                case .success(let data):
                    completion(.success(data))
                case .failure(_):
                    completion(.failure(.noRequest))
                }
            }
    }
}
