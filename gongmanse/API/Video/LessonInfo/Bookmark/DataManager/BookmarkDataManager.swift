//
//  BookmarkDataManager.swift
//  gongmanse
//
//  Created by 김우성 on 2021/05/31.
//

import Alamofire

struct DeleteBookmarkInput: Encodable {
    
    var token: String
    var video_id: String
}


class BookmarkDataManager {
    
    /* 02015. 동영상 즐겨찾기 추가 */
    func addBookmarkToVideo(_ parameters: BookmarkInput, viewController: LessonInfoController) {
        
        // Input 데이터
        let url = "\(Constant.BASE_URL)/v/member/mybookmark"
        let data = parameters
        let param: Parameters = [
            "token": data.token,
            "video_id": data.video_id
        ]
        
        // POST
        AF.request(url, method: .post, parameters: param, encoding: JSONEncoding.default, headers: nil)
            // API에서 성공했을 시, 아무 응답이 없고 실패했을 시 DB Error Log를 호출한다.
            // 그러므로 Response에 대한 Decoding 전략은 작성하지 않았다. (정확히 말하면 필요가 없음)
            .responseString { response in
                print("DEBUG: 즐겨찾기 추가 API Response \(response)")
            }
    }
    
    func deleteBookmarkToVideo(_ parameters: DeleteBookmarkInput, viewController: LessonInfoController) {
        
        let url = "\(Constant.BASE_URL)/v/member/mybookmark"
        let param: Parameters =
            [
            "token"     : parameters.token,
            "video_id"  : parameters.video_id,
            ]
        
        // PATCH
        AF.request(url,
                   method: .patch,
                   parameters: param,
                   encoding: URLEncoding.httpBody,
                   headers: nil,
                   interceptor: nil,
                   requestModifier: nil)
            
            // API에서 성공했을 시, 아무 응답이 없고 실패했을 시 DB Error Log를 호출한다.
            // 그러므로 Response에 대한 Decoding 전략은 작성하지 않았다. (정확히 말하면 필요가 없음)
            .responseString { response in
                print("DEBUG: 즐겨찾기 삭제 API Response \(response)")
            }
    }
    
    
}
