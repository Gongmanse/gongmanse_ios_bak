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

struct postFilteringAPI {
    
    
    //Get 방식
    func performGetFiltering(token: String, grade: String, subject: String) {
        let urls = "\(apiBaseURL)/v/setting/settingios?token=\(token)&grade=\(grade)&subject=\(subject)"
        
        let ttt = urls.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        guard let url = URL(string: ttt) else { return }
        let req = AF.request(url)
        req.responseString { (response) in
            print(response.result)
        }
       
    }
    
    
    func performFiltering(_ token: String?, _ grade: String?, _ subject: String?) {
        let filterUrl = "https://api.gongmanse.com/v/setting/searchsetting"
        guard let token = token else { return }
        guard let grade = grade else { return }
        guard let subject = subject else { return }
        
        
        let parameters = [
            "token":token,
            "grade":grade,
            "subject":subject
        ]
        print(parameters)
        let request = URLRequest(url: URL(string: filterUrl)!)
        
        AF.request(request)
            .responseString { (response) in
                print(response.result)
            }
        
        
        // 왜 실패?
        //        AF.upload(multipartFormData: { MultipartFormData in
        //
        //            MultipartFormData.append(tokens.data(using: .utf8) ?? Data(), withName: "token")
        //            MultipartFormData.append(tokens1.data(using: .utf8) ?? Data(), withName: "grade")
        //            MultipartFormData.append(tokens2.data(using: .utf8) ?? Data(), withName: "subject")
        //
        //        }, to: filterUrl)
        
        //        // Result를 Response 타입에 맞게 변환
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
        
        
    }
}


struct getFilteringAPI {
    let getfilterUrl = "\(apiBaseURL)/v/setting/searchsetting?token=MTM0NzQ2ZTIxOGNmM2Y1NmI4NTExYWMwODEzYzRmMDg5YmI5YzIzN2FlODE4NTExNTY1NTFkOGEzMmIzN2VkYTFmNjdkYjQ0OTU5MjQxNWM0OWQ1NDRmZDEwYmE0ZWEwYmU4NjkyYzgwNjdiMWU1YTUyNjg0NTI2NGU1YzJiYzVZTnY4SVcvaFhOM2J3Zm5mUDVvTFFsVlNWNDAzTi8zZUtGbzRVZHBYc1o0OUhndVN6NzFOL2d4eXFCWkxOMkZSdkJiL1lLMlBsSlJTZ2F6OTFyckU4QT09"
    
    func getFilteringData(complition: @escaping (_ result: SubjectGetDataModel) -> Void) {
        AF.request(getfilterUrl)
            .responseDecodable(of: SubjectGetDataModel.self) { response in
                switch response.result {
                case .success(let response):
                    // controller code
                    let json = response
                    
                    print(json)
                    complition(json)
                    
                case .failure(let error):
                    print("DEBUG: faild connection \(error.localizedDescription)")
                }
            }
    }
}
