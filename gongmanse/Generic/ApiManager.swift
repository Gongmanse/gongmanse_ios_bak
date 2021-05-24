//
//  ApiTypealias.swift
//  gongmanse
//
//  Created by wallter on 2021/05/07.
//

import UIKit
import Alamofire



// Result의 Generic
typealias resultModel<T> = (Result<T, InfoError>) -> Void



// Get 메소드용
func getAlamofireGeneric<T: Codable>(url: inout String,
                                     isConvertUrl: Bool,
                                     completion: @escaping (T) -> Void) {
    
    if isConvertUrl {
        url = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
    }
    
    AF.request(url, method: .get)
        .responseDecodable(of: T.self) { response in
            switch response.result {
            case .success(let data):
                completion(data)
            case .failure(let err):
                completion(err as! T)
            }
        }
}

