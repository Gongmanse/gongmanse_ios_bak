//
//  LectureAPIManager.swift
//  gongmanse
//
//  Created by wallter on 2021/05/17.
//

import Foundation
import Alamofire


struct LectureAPIManager {
    

    var url: String?
    
    init(_ grade: String, _ offset: String) {
        url = "\(apiBaseURL)/v/video/byteacher?grade=\(grade)&offset=\(offset)"
    }
    
    // 강사별 보기
    func initializeApi(completion: @escaping resultModel<LectureModel>) {
        
        if let urls = url {
            guard let endcodeUrl = urls.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
            AF.request(endcodeUrl, method: .get)
                .responseDecodable(of: LectureModel.self) { response in
                    switch response.result {
                    case .success(let data):
                        completion(.success(data))
                    case .failure(let err):
                        print(err.localizedDescription)
                        completion(.failure(.noRequest))
                    }
                }
        }
    }
    
    
}
