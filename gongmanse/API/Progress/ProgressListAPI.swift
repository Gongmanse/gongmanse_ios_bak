//
//  RequestProgressAPI.swift
//  gongmanse
//
//  Created by wallter on 2021/04/15.
//

import Foundation
import Alamofire
/* * Subject Infomation
 
    subject → 과목 : 국영수 (34), 과학 (35), 사회 (36), 기타 (37)
    grade → 학교 : 모든, 초등, 중등, 고등
    gradeNum → 학년 : 0, 1, 2, 3, 4, 5, 6
*/

struct ProgressAPI {
    static let progress = "v3/progress"
}

struct ProgressListAPI {
    
    let url: String?
    
    init(subject: Int, grade: String, gradeNum: Int, offset: Int, limit: Int) {
        url = "\(apiBaseURL)/\(ProgressAPI.progress)/record/\(subject)?grade=\(grade)&gradeNum=\(gradeNum)&offset=\(offset)&limit=\(limit)"
    }
    
    func requestProgressDataList(completion: @escaping (_ result: ProgressPopupModel) -> Void) {
        
        guard let urlEncoded = url?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return
        }
        
        AF.request(urlEncoded, method: .get)
            .responseDecodable(of: ProgressPopupModel.self) { response in
                switch response.result {
                case .success(let json):
                    completion(json)
                case .failure(let error):
                    print("DEBUG: ", error.localizedDescription)
                }
        }
    }
    
     
    
}
