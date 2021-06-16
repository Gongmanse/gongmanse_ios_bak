//
//  VideoQnAAPIManager.swift
//  gongmanse
//
//  Created by wallter on 2021/05/14.
//

import Foundation
import Alamofire

struct VideoQnAAPIManager {
    
    // QnA 목록 불러오는 메서드
    
    func fetchVideoQnAGetApi(_ videoId: String, _ token: String, completion: @escaping resultModel<VideoQnAModel>) {
        
        print(videoId)
        print(token)
        
        let videoUrl = "\(apiBaseURL)/v/video/detail_qna?video_id=\(videoId)&token=\(token)"
        
        AF.request(videoUrl, method: .get)
            .responseDecodable(of: VideoQnAModel.self) { response in
                switch response.result {
                case .success(let data):
                    completion(.success(data))
                case .failure(let err):
                    print(err.localizedDescription)
                    completion(.failure(.noRequest))
                }
            }
    }
    
    // QnA 목록 추가하는 메서드
    
    func fetchVideoQnAInsertApi(_ parameter: VideoQnAPostModel, completion: @escaping () -> Void ) {
        let data = parameter
        
        let videoPostUrl = "\(apiBaseURL)/v/video/detail_qna"
        print(data)
        
        AF.upload(multipartFormData: {
            $0.append(data.token.data(using: .utf8)!, withName: "token")
            $0.append(data.videoID.data(using: .utf8)!, withName: "video_id")
            $0.append(data.content.data(using: .utf8)!, withName: "content")
        }, to: videoPostUrl)
        
        .response(completionHandler: { response in
            switch response.result {
            case .success(_):
                completion()
            case .failure(_):
                completion()
            }
        })
    }
}
