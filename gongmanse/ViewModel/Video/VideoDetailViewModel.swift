//
//  VideoDetailViewModel.swift
//  gongmanse
//
//  Created by wallter on 2021/05/27.
//

import Foundation

class VideoDetailViewModel {
    
    var detailModel: VideoDetailInfoModel?
    
    var commantaryID: String?
    var videoID: String?
    
    let tokens = "YTRjZTA2OGJhNmQyZTc4MTE4MGRjODIwMWQyZjYyZDBjYjE1MWNmZDNjZTAyYzU1Yjk5NDRjZTE5YTc1Y2MwYmFhYmY3NmM3NjIxNTIxNWM3YmRkYjcxZTU0ZmQ4NGI2ODM1Zjg3ZmMwNmE5MzhlODE5MjlhZDcxODcyZGRjNjJQd1RvakgwaGZiTGowQjVHU2ZRNnRDWGNmVjZkTGt4Y0Evc1FWanYzRVgwcXRScld2M2xyMllFSktNQ1B1QTQ1akNjQ0RKbUxsUWpGVTdtbXJTcDEzdz09"
    
    func requestVideoDetailApi(_ videoID: String) {
        
        var detailUrl = "\(apiBaseURL)/v/video/details?video_id=\(videoID)&token=\(tokens)"
        
        getAlamofireGeneric(url: &detailUrl, isConvertUrl: false) { (response: Result<VideoDetailInfoModel, InfoError>) in
            switch response {
            case .success(let data):
                self.commantaryID = data.data.iCommentaryId
                self.videoID = data.data.id
                self.detailModel = data
            case .failure(let err):
                print(err.localizedDescription)
            }
            
        }
    }
}
