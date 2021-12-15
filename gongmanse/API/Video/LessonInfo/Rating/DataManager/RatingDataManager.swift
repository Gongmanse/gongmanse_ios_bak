//
//  RatingDataManager.swift
//  gongmanse
//
//  Created by 김우성 on 2021/05/31.
//

import Alamofire

class RatingDataManager {
    
    /* 02017. 동영상 평점 추가 */
    func addRatingToVideo(_ parameters: RatingInput, viewController: RatingController) {
        
        // Input 데이터
        let url = "\(apiBaseURL)/v/member/myrating"
        let data = parameters
        
        let param: Parameters = [ "token": data.token,
                                  "video_id": data.video_id,
                                  "rating": data.rating]
        
        // POST
        AF.request(url, method: .post, parameters: param, encoding: JSONEncoding.default, headers: nil)
            // API에서 성공했을 시, 아무 응답이 없고 실패했을 시 DB Error Log를 호출한다.
            // 그러므로 Response에 대한 Decoding 전략은 작성하지 않았다. (정확히 말하면 필요가 없음)
            .responseString { response in
                print("DEBUG: 평점 추가 API Response \(response)")
                viewController.refreshUserRating()
            }
    }
    
    // 21.05.31 기준
    // 평점 삭제 API는 있는데 앱에 보면 평점 삭제 기능을 사용하는 곳은 없음. 아래 메소드 사용하는 곳은 없음
    // 추후 사용할 일 있을 수 있어서 기록해둠
    func deleteBookmarkToVideo(_ parameters: RatingInput, viewController: LessonInfoController) {
        
        let url = "\(Constant.BASE_URL)/v/member/myrating"
        let data = parameters
        let param: Parameters =
            [
            "token"     : data.token,
            "video_id"  : String(data.video_id),
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
                print("DEBUG: 평점 삭제 API Response \(response)")
            }
    }
}
