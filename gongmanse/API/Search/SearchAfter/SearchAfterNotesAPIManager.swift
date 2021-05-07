//
//  SearchAfterNotesAPIManager.swift
//  gongmanse
//
//  Created by wallter on 2021/05/06.
//

import UIKit
import Alamofire


struct SearchAfterNotesAPIManager  {
    
    let url = "\(apiBaseURL)/v/search/searchnotes"
    
    func fetchNotesAPI(_ parameter: SearchNotesPostModel,
                       completion: @escaping resultModel<SearchNotesModel>) {
        
        
        let data = parameter
        
        AF.upload(multipartFormData: { formData in
            
            formData.append("\(data.subject ?? "")".data(using: .utf8) ?? Data(), withName: "subject")
            formData.append("\(data.grade ?? "")".data(using: .utf8) ?? Data(), withName: "grade")
            formData.append("\(data.keyword ?? "")".data(using: .utf8) ?? Data(), withName: "keyword")
            formData.append("\(data.offset ?? "0")".data(using: .utf8) ?? Data(), withName: "offset")
            formData.append("\(data.sortID ?? "4")".data(using: .utf8) ?? Data(), withName: "sort_id")
            
            
        }, to: url)
        .responseDecodable(of: SearchNotesModel.self) { response in
            switch response.result {
            case .success(let data):
                completion(.success(data))
            case .failure(_):
                completion(.failure(.noRequest))
            }
        }
    }
}
