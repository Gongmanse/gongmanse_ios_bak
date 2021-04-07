//
//  RequestSubjectAPI.swift
//  gongmanse
//
//  Created by wallter on 2021/04/07.
//

import Foundation
import Alamofire



struct getSubjectAPI {
    
    let subjecturl = "\(apiBaseURL)/v/search/subjectnum?offset=0&limit=100"
    
    func requestSubjectAPI(complition: @escaping (_ result: [SubjectModel]) -> Void ) {
        AF.request(subjecturl)
            .responseDecodable(of: SubjectListModel.self) { response in
                switch response.result {
                case .success(let response):
                    // controller code
                    let json = response
                    let notice = json.data
                    complition(notice)
                    
                case .failure(let error):
                    print("DEBUG: faild connection \(error.localizedDescription)")
                }
            }
    }
    
}
