//
//  SearchAfterConsultationAPIManager.swift
//  gongmanse
//
//  Created by wallter on 2021/05/06.
//

import Foundation
import Alamofire



struct SearchAfterConsultationAPIManager {
    
    let url = "\(apiBaseURL)/v/search/search_consultation"
    
    
    
    func fetchConsultaionAPI(_ parameter: SearchConsultationPostModel,
                             completion: @escaping resultModel<SearchConsultationModel>) {
        
        let data = parameter
        AF.upload(multipartFormData: { formData in
            formData.append("\(data.keyword ?? "")".data(using: .utf8) ?? Data(), withName: "keyword")
            formData.append("\(data.sortID ?? "")".data(using: .utf8) ?? Data(), withName: "sort_id")
            formData.append("\(data.offset ?? "0")".data(using: .utf8) ?? Data(), withName: "offset")
        }, to: url)
        .responseDecodable(of: SearchConsultationModel.self) { response in
            switch response.result {
            case .success(let data):
                completion(.success(data))
            case .failure(_):
                completion(.failure(.noRequest))
            }
        }
        
    }
}
