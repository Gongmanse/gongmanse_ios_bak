//
//  ShareDataManager.swift
//  gongmanse
//
//  Created by H on 2021/08/02.
//

import Alamofire

struct ShareCount: Codable {
    let countFiltered: Int
}

struct Share: Codable {
    let data: ShareData
}

struct ShareData: Codable {
    let share_url: String
}

class ShareDataManager {
    
    // 공유 URL 횟수 체크
    func getShareCount(_ token: String, completionHandler: @escaping (_ countFiltered: Int) -> Void) {
        
        // Input 데이터
        let url = "\(Constant.BASE_URL)/v1/my/video/statistics?token=\(token)&for_today=1&filter[target]=field&filter[value]=iShare"
        
        AF.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil)
            .responseDecodable(of: ShareCount.self) { response in
                switch response.result {
                case .success(let data):
                    completionHandler(data.countFiltered)
                case .failure(let err):
                    print("getShareCount, Failure: \n", err.localizedDescription)
                }
            }
    }
    
    // 공유 URL
    func getShareURL(_ videoId: String, completionHandler: @escaping (_ shareUrl: String) -> Void) {
        
        // Input 데이터
        let url = "\(Constant.BASE_URL)/v/video/sharekey?video_id=\(videoId)"
        
        AF.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil)
            .responseDecodable(of: Share.self) { response in
                switch response.result {
                case .success(let data):
                    completionHandler(data.data.share_url)
                case .failure(let err):
                    print("getShareCount, Failure: \n", err.localizedDescription)
                }
            }
    }
    
    // 공유 URL 횟수 업데이트
    func updateShareCount(_ token: String, _ videoId: String, _ socialType: String, completionHandler: @escaping () -> Void) {
        
        // Input 데이터
        let url = "\(Constant.BASE_URL)/v/video/sharekey?token=\(token)&video=\(videoId)&field=iShare&value=\(socialType)"
        
        AF.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil)
            .response(completionHandler: { response in
                completionHandler()
            })
    }
}
