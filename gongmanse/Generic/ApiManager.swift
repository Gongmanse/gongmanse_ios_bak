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
/*
 
 inout 용 URL은 함수 내 지역변수로 설정하길 권장합니다
 메모리 접근 이슈가 있네요.
 
 */
func getAlamofireGeneric<T: Codable>(url: inout String,
                                     isConvertUrl: Bool,
                                     completion: @escaping (Result<T, InfoError>) -> Void) {
    
    if isConvertUrl {
        url = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
    }
    
    AF.request(url, method: .get)
        .responseDecodable(of: T.self) { response in
            switch response.result {
            case .success(let data):
                completion(.success(data))
            case .failure(_):
                completion(.failure(.noRequest))
            }
        }
}

