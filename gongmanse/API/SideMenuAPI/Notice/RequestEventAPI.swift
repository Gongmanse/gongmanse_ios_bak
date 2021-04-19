//
//  RequestEventAPI.swift
//  gongmanse
//
//  Created by wallter on 2021/04/14.
//

import Foundation
import Alamofire

struct RequestEventListAPI {
    
    let eventListUrl: String

    init(offset: Int) {
        eventListUrl = "\(apiBaseURL)/v/setting/settingevent?offset=\(offset)&limit=20"
    }
   
    func getRequestEvent(complition: @escaping (_ result: [EventModel]) -> Void) {
     
        AF.request(eventListUrl, method: .get)
            .responseDecodable(of: EventListModel.self) { response in
            switch response.result {
            case .success(let success):
                let json = success
                
                
                complition(json.data)
            case .failure(let error):
                print("DEBUG: ", error.localizedDescription)
            }
        }
    }
}
