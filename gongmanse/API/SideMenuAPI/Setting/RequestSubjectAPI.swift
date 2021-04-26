//
//  RequestSubjectAPI.swift
//  gongmanse
//
//  Created by wallter on 2021/04/07.
//

import Foundation
import Alamofire


// 서버에서 과목List 받아오는 API
struct getSubjectAPI {
    
    let subjecturl = "\(apiBaseURL)/v/search/subjectnum?offset=0&limit=100"
    
    func performSubjectAPI(complition: @escaping (_ result: [SubjectModel]) -> Void ) {
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

// 데이터 서버에 보낼 때
struct postFilteringAPI {
    
    
    // Get 방식 현재 사용중인 API
    func performGetFiltering(token: String, grade: String, subject: String) {
        let urls = "\(apiBaseURL)/v/setting/settingios?token=\(token)&grade=\(grade)&subject=\(subject)"
        print(urls)
        let urlEncoding = urls.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "Url: URL Empty"
        
        guard let url = URL(string: urlEncoding) else { return }
        let req = AF.request(url)
        req.responseString { (response) in
            print(response.result)
        }
       
    }
    
    // POST방식, 아직 고민중
//    func performFiltering(_ token: String?, _ grade: String?, _ subject: String?) {
//        let filterUrl = "https://api.gongmanse.com/v/setting/searchsetting"
//        guard let token = token else { return }
//        guard let grade = grade else { return }
//        guard let subject = subject else { return }
//        let gradeEncoding = grade.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "@"
//
//        let parameters = [
//            "token":token,
//            "grade":gradeEncoding,
//            "subject":subject
//        ]
//
//        print(parameters)
//        let request = URLRequest(url: URL(string: filterUrl)!)
//
//        AF.request(request)
//            .responseString { (response) in
//                print(response.result)
//            }
        
        
        // 왜 실패?
//        AF.upload(multipartFormData: { MultipartFormData in
//
//            MultipartFormData.append(token.data(using: .utf8) ?? Data(), withName: "token")
//            MultipartFormData.append(gradeEncoding.data(using: .utf8) ?? Data(), withName: "grade")
//            MultipartFormData.append(subject.data(using: .utf8) ?? Data(), withName: "subject")
//
//        }, to: filterUrl)
        // Result를 Response 타입에 맞게 변환
//        .responseDecodable(of: SubejectFilterModel.self) { response in
//            switch response.result {
//            case .success(let response):
//                print(response)
//
//            case .failure(let error):
//                // 연결 실패
//                print("DEBUG: failed connection \(error.localizedDescription)")
//            }
//        }
//    }
}

// 보낸 데이터 받아오는 API
struct getFilteringAPI {
    
    let token = "NWI0NjRiZDU0YTgyYjFhZTU1OGRmZDljZjBlYThmMDNmNWU0OTc1YjgyODNkMGM5ZDYxYjMzOWIyYTc2OGQxZTkxYWM4ZTk2ZTczMGExZTMwY2UwYzcxNWU0MGI3YjA0NzRmODVhZTE0NTc3ODQyMWIyZjQyM2JiOWU3OWY0MjNqbUFESlhOT1VhREFPQVdqZUErWUlGSkhyZU91Y3BSR2JWcmZyVG1kTTRCYTlaejhlSWdQanl4VUF6b1QrR3Bjb0tzRythdTlGMVY5QzJzZ3NmQTVkUT09"
    
    func getFilteringData(complition: @escaping (_ result: SubjectGetDataModel) -> Void) {
        
        let getfilterUrl = "\(apiBaseURL)/v/setting/searchsetting?token=\(token)"
        print(getfilterUrl)
        
        AF.request(getfilterUrl)
            .responseDecodable(of: SubjectGetDataListModel.self) { response in
                switch response.result {
                case .success(let response):
                    // controller code
                    let json = response
                    
                    complition(json.data)
                    
                case .failure(let error):
                    
                    print("DEBUG: faild connection \(error.localizedDescription)")
                    
                }
            }
    }
}
