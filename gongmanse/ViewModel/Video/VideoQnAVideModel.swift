//
//  VideoQnAVideModel.swift
//  gongmanse
//
//  Created by wallter on 2021/05/14.
//

import Foundation

class VideoQnAVideModel {
    
    weak var reloadDelegate: TableReloadData?
    
    var videoQnAInformation: VideoQnAModel?
    
    let videoQnAManager = VideoQnAAPIManager()
    
    func requestVideoQnA(_ videoId: String) {
        
        videoQnAManager.fetchVideoQnAGetApi(videoId, Constant.testToken) { response in
            
            switch response {
            case .success(let data):
                self.videoQnAInformation = data
                self.reloadDelegate?.reloadTable()
            case .failure(let err):
                print(err.localizedDescription)
            }
        }
    }
    
    
    func requestVideoQnAInsert(_ videoId: String, content: String) {
        
        let parameters = VideoQnAPostModel(videoID: videoId, token: Constant.testToken, content: content)
        
        videoQnAManager.fetchVideoQnAInsertApi(parameters) {
            print("Success QnA Insert")
        }
    }
}