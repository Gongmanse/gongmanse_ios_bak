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
    
    var isLoading = false
    
    /// 영상QnA 정보 불러오기
    func requestVideoQnA(_ videoId: String) {
        isLoading = true
        
        videoQnAManager.fetchVideoQnAGetApi(videoId, Constant.token) { response in
            self.isLoading = false
            
            switch response {
            case .success(let data):
                print("Success Request")
                self.videoQnAInformation = data
                self.videoQnAInformation?.data.removeAll()
                for i in 0 ..< data.data.count {
                    let item = data.data[i]
                    if item.sTeacher != nil {
                        do {
                            var item1 = try data.data[i].copy()
                            item1.sTeacher = nil
                            self.videoQnAInformation?.data.append(item1)
                        } catch {
                            
                        }
                        self.videoQnAInformation?.data.append(item)
                    } else {
                        self.videoQnAInformation?.data.append(data.data[i])
                    }
                }
                
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
            self.requestVideoQnA(videoId)
        }
    }
}
