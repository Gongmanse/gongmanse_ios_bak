//
//  GuestKeyDataManager.swift
//  gongmanse
//
//  Created by 김우성 on 2021/06/17.
//

import Foundation
import Alamofire

class GuestKeyDataManager {
    
    func GuestKeyAPIGetData(videoID: String, viewController: VideoController) {
        
        // viewModel -> paramters 를 통해 값을 전달한다.
        let videoID = videoID
        
        // URL을 구성한다.
        let url = "https://api.gongmanse.com/v/video/recommendurl?video_id=\(videoID)&token="
        
        /// HTTP Method: GET
        /// API 명: "02023. 추천 동영상 비디오 경로"
        AF.request(url)
            .responseDecodable(of: GuestKeyResponse.self) { response in
                
                switch response.result {
                case .success(let response):
                    print("DEBUG: 게스트키 API 통신 성공")
                    print("DEBUG: 통신한 데이텨 결과 \(response.data)")
                    viewController.networkingByGuestKey(response: response)
                    
                case .failure(let error):
                    print("DEBUG: 게스트키 API 통신 실패")
                    print("DEBUG: faild connection \(error.localizedDescription)")
                }
            }
    }
    
    func GuestKeyAPIGetNoteData(videoID: String, viewController: LectureNoteController) {
        
        // viewModel -> paramters 를 통해 값을 전달한다.
        let videoID = videoID
        
        // URL을 구성한다.
        let url = "https://api.gongmanse.com/v/video/recommendnotes?video_id=\(videoID)"
        
        /// HTTP Method: GET
        /// API 명: "02025. 추천 동영상 비디오 노트"
        AF.request(url)
            .responseDecodable(of: GuestKeyNoteResponse.self) { response in
                
                switch response.result {
                case .success(let response):
                    print("DEBUG: 게스트키 노트 API 통신 성공")
                    viewController.getNoteImageFromGuestKeyNoteAPI(response: response)
                    
                case .failure(let error):
                    print("DEBUG: 게스트키 노트 API 통신 실패")
                    print("DEBUG: faild connection \(error.localizedDescription)")
                }
            }
    }
    
    func GuestKeyAPIGetNoteData(videoID: String, viewController: LessonNoteController) {
        
        // viewModel -> paramters 를 통해 값을 전달한다.
        let videoID = videoID
        
        // URL을 구성한다.
        let url = "https://api.gongmanse.com/v/video/recommendnotes?video_id=\(videoID)"
        
        /// HTTP Method: GET
        /// API 명: "02025. 추천 동영상 비디오 노트"
        AF.request(url)
            .responseDecodable(of: GuestKeyNoteResponse.self) { response in
                
                switch response.result {
                case .success(let response):
                    print("DEBUG: 게스트키 노트 API 통신 성공")
                    viewController.getNoteImageFromGuestKeyNoteAPI(response: response)
                    
                case .failure(let error):
                    print("DEBUG: 게스트키 노트 API 통신 실패")
                    print("DEBUG: faild connection \(error.localizedDescription)")
                }
            }
    }
}



struct GuestKeyResponse: Decodable {
    
    var data: GuestKeyData
}
struct GuestKeyData: Decodable {
    
    var sTitle : String
    var sTags: String
    var sTeacher: String
    var sThumbnail: String
    var sSubtitle: String
    var iRating: String
    var sSubject: String
    var sSubjectColor: String
    var iCategoryId: String
    var iSeriesId: String
    var iCommentaryId: String
    var iHasCommentary: String
    var sUnit: String
    var source_url: String
}

struct GuestKeyNoteResponse: Decodable {
    
    var sNotes: [String]
}
