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
    
    func requestVideoQnA(_ videoId: String) {
        
        let videoQnAManager = VideoQnAAPIManager()
        
        videoQnAManager.fetchVideoQnAApi(videoId, Constant.testToken) { response in
            switch response {
            case .success(let data):
                self.videoQnAInformation = data
                self.reloadDelegate?.reloadTable()
            case .failure(let err):
                print(err.localizedDescription)
            }
        }
    }
}
