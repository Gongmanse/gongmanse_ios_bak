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
    var isCommentary: Bool = false
    
    
    let tokens = "YWI3NmY2MzE5ZjEwNTYwNGYxYzg3YzE0NmEwNDhkNTA5NzVhODc0YjA2MzIzNmUxNThlMmM0YmZjMWQxZGUxMjNkYWQwYjQ3NGIxNmQzMzNlMjBiMGY2NzA1YzJhMmFiYWIwMDAwMjkzODg2NzE2MTNkMjE4ZGQ0MjViYzIzYmJ5bWJ3RDR1OWhpTGoxSEhGSUZrb3pnbFZ3ZzZMQUsyUFVhbkZBcUdYYU5qZDRxSUhuUnpsQUVldFRHeDBsbUVoQzhKU2JBWUJteFAyMzFLU3NYRlpwUT09"
    
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
