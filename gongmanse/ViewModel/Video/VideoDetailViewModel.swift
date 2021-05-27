//
//  VideoDetailViewModel.swift
//  gongmanse
//
//  Created by wallter on 2021/05/27.
//

import Foundation

class VideoDetailViewModel {
    
    var detailModel: VideoDetailInfoModel?
    
    
    func requestVideoDetailApi(_ videoID: String) {
        
        var detailUrl = "https://api.gongmanse.com/v/video/details?video_id=\(videoID)&token=\(Constant.token)"
        
        getAlamofireGeneric(url: &detailUrl, isConvertUrl: false) { (response: Result<VideoDetailInfoModel, InfoError>) in
            switch response {
            case .success(let data):
                self.detailModel = data
            case .failure(let err):
                print(err.localizedDescription)
            }
            
        }
    }
}
