//
//  VideoDetailViewModel.swift
//  gongmanse
//
//  Created by wallter on 2021/05/27.
//

import Foundation
import UIKit

class VideoDetailViewModel {
    
    var detailModel: VideoDetailInfoModel?
    
    var commantaryID: String?
    var videoID: String?
    var isCommentary: Bool = false
    
    
    let tokens = Constant.token
    
    func requestVideoDetailApi(_ videoID: String, _ btn: UIView, completion: @escaping () -> Void) {
        
        var detailUrl = "\(apiBaseURL)/v/video/details?video_id=\(videoID)&token=\(tokens)"
        
        getAlamofireGeneric(url: &detailUrl, isConvertUrl: false) { (response: Result<VideoDetailInfoModel, InfoError>) in
            switch response {
            case .success(let data):
                self.commantaryID = data.data.iCommentaryId
                self.videoID = data.data.id
                self.detailModel = data
                btn.isHidden = self.commantaryID == "0"
                
                completion()
            case .failure(let err):
                print(err.localizedDescription)
            }
            
        }
    }
}
