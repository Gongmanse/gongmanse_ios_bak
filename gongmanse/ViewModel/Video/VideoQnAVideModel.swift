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
    
    /// 영상QnA 정보 불러오기
    func requestVideoQnA(_ videoId: String) {
        
        videoQnAManager.fetchVideoQnAGetApi(videoId, Constant.token) { response in
            
            switch response {
            case .success(let data):
                print("Success Request")
                self.videoQnAInformation = data
                self.reloadDelegate?.reloadTable()
            case .failure(let err):
                print(err.localizedDescription)
            }
        }
    }
    
    /// 영상 QnA 데이터 넣기
    func requestVideoQnAInsert(_ videoId: String, content: String) {
        
        let parameters = VideoQnAPostModel(videoID: videoId, token: Constant.token, content: content)
        
        videoQnAManager.fetchVideoQnAInsertApi(parameters) {
            print("Success QnA Insert")
        }
    }
}
