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
        /// API 명: "02008. 동영상 상세 정보"
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

//struct DetailVideoResponse: Decodable {
//    var data: DetailVideoData
//}
//
//
//struct DetailVideoData: Decodable {
//    var id: String              // 영상 ID
//    var sTitle: String          // 영상 제목
//    var iHasCommentary: String  // 댓글 수
//    var iSeriesId: String       // 시리즈 ID
//    var iCommentaryId: String   // 댓글 ID
//    var sTags: String           // 영상에 있는 태그
//    var sTeacher: String        // 선생님 이름
//    var dtDateCreated: String   // 영상 생성일자
//    var dtLastModified: String  // 영상 수정일자
//    var iRating: String         // 영상 평점
//    var iRatingNum: String      // 영상 평가 수
//    var sHighlight: String?     // 자막 중, 하이라이트 된 문장
//    var sBookmarks: Bool        // 북마크 인덱스
//    var sThumbnail: String      // 썸네일 이미지
//    var sVideopath: String      // 영상파일 URL
//    var sSubtitle: String       // 자막 URL
//    var sUnit: String           // 과목 코드
//    var iUserRating: String?    // 사용자 평가
//    var sSubject: String        // 과목 태그
//    var sSubjectColor: String   // 과목 태그 색상
//    var iCategoryId: String     // 카테고리 ID
//    var source_url: String?     // 영상 URL
//}
