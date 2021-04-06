//
//  RequestNoticeAPI.swift
//  gongmanse
//
//  Created by taeuk on 2021/04/05.
//

import Foundation
import Alamofire



struct getNoticeList {
    
    let noticeListURL = apiBaseURL+"/v/setting/notice"
    
    func requestNoticeList(complition: @escaping (_ result: [NoticeList]) -> Void) {
        print(noticeListURL)
        AF.request(noticeListURL)
            .responseDecodable(of: NoticeListModel.self) { response in
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
