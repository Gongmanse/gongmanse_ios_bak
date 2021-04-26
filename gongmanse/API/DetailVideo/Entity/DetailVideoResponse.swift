//
//  DetailVideoResponse.swift
//  gongmanse
//
//  Created by 김우성 on 2021/04/26.
//

import Foundation

struct DetailVideoResponse: Decodable {
    
    var data: DetailVideoData
}


struct DetailVideoData: Decodable {
    
    var id: String              // 영상 ID
    var sTitle: String          // 영상 제목
    var iHasCommentary: String  // 댓글 수
    var iSeriesId: String       // 시리즈 ID
    var iCommentaryId: String   // 댓글 ID
    var sTags: String           // 영상에 있는 태그
    var sTeacher: String        // 선생님 이름
    var dtDateCreated: String   // 영상 생성일자
    var dtLastModified: String  // 영상 수정일자
    var iRating: String         // 영상 평점
    var iRatingNum: String      // 영상 평가 수
    var sHighlight: String?     // 자막 중, 하이라이트 된 문장
    var sBookmarks: String      // 북마크 인덱스
    var sThumbnail: String      // 썸네일 이미지
    var sVideopath: String      // 영상파일 URL
    var sSubtitle: String       // 자막 URL
    var sUnit: String           // 과목 코드
    var iUserRating: String?    // 사용자 평가
    var sSubject: String        // 과목 태그
    var sSubjectColor: String   // 과목 태그 색상
    var iCategoryId: String     // 카테고리 ID
    var source_url: String?      // 영상 URL
    

}
