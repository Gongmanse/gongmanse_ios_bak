//
//  RequestLectureListAPI.swift
//  gongmanse
//
//  Created by wallter on 2021/04/14.
//

import Foundation
import Alamofire

struct RequestLectureListAPI {
    
    let lectureUrl: String?
    
    init(offset: Int) {
        lectureUrl = "\(apiBaseURL)/v/video/byteacher?limit=20&offset=\(offset)"
    }
    
    func requestLectureList(complition: @escaping (_ result: [LectureThumbnail]) -> Void ) {
        AF.request(lectureUrl ?? "not url", method: .get)
            .responseDecodable(of: LectureListModel.self) { response in
                
                switch response.result {
                
                case.success(let json):
                    let tt = json
                    let ttt = tt.data
                    complition(ttt)
                case .failure(let err):
                    print("DEBUG: faild connection: ", err.localizedDescription)
            }
        }
    }
}
