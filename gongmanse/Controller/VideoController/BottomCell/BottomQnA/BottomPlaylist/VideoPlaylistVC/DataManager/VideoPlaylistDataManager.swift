//
//  VideoPlaylistDataManager.swift
//  gongmanse
//
//  Created by 김우성 on 2021/06/16.
//

import Foundation
import Alamofire

class VideoPlaylistDataManager {
    
    func getJindoDetail(_ jindo_id: String, _ offset: Int, _ limit: Int, _ viewController: VideoPlaylistVC) {
        // URL을 구성한다.
        let url = apiBaseURL + "/v/jindo/jindo_details?jindo_id=\(jindo_id)&offset=\(offset)&limit=\(limit)"
        
        /// HTTP Method: GET
        AF.request(url)
            .responseDecodable(of: VideolistResponse.self) { response in
                
                switch response.result {
                case .success(let response):
                    viewController.didSuccessAddVideolistInAutoplaying(response)
                    
                case .failure(let error):
                    print("DEBUG: 재생목록 API 통신 실패")
                    print("DEBUG: faild connection \(error.localizedDescription)")
                }
            }
    }
    
    func getSubjectList(_ category_id: Int, _ commentary: Int, _ sort_id: Int, _ offset: Int, _ limit: Int, _ viewController: VideoPlaylistVC) {
        
        // URL을 구성한다.
        let url = apiBaseURL + "/v/video/bycategory?category_id=\(category_id)&commentary=\(commentary)&sort_id=\(sort_id)&offset=\(offset)&limit=\(limit)"
        
        /// HTTP Method: GET
        AF.request(url)
            .responseDecodable(of: VideolistResponse.self) { response in
                
                switch response.result {
                case .success(let response):
                    viewController.didSuccessAddVideolistInAutoplaying(response)
                    
                case .failure(let error):
                    print("DEBUG: 재생목록 API 통신 실패")
                    print("DEBUG: faild connection \(error.localizedDescription)")
                }
            }
    }
    
    func getRecentVideoList(_ token: String, _ sort_id: Int, _ offset: Int, _ limit: Int, _ viewController: VideoPlaylistVC) {
        // URL을 구성한다.
        let url = apiBaseURL + "/v/member/watchhistory?token=\(token)&sort_id=\(sort_id)&offset=\(offset)&limit=\(limit)"
        
        /// HTTP Method: GET
        AF.request(url)
            .responseDecodable(of: VideolistResponse.self) { response in
                
                switch response.result {
                case .success(let response):
                    viewController.didSuccessAddVideolistInAutoplaying(response)
                    
                case .failure(let error):
                    print("DEBUG: 재생목록 API 통신 실패")
                    print("DEBUG: faild connection \(error.localizedDescription)")
                }
            }
    }
    
    func getBookMarkList(_ token: String, _ sort_id: Int, _ offset: Int, _ limit: Int, _ viewController: VideoPlaylistVC) {
        // URL을 구성한다.
        let url = apiBaseURL + "/v/member/mybookmark?token=\(token)&sort_id=\(sort_id)&offset=\(offset)&limit=\(limit)"
        
        /// HTTP Method: GET
        AF.request(url)
            .responseDecodable(of: VideolistResponse.self) { response in
                
                switch response.result {
                case .success(let response):
                    viewController.didSuccessAddVideolistInAutoplaying(response)
                    
                case .failure(let error):
                    print("DEBUG: 재생목록 API 통신 실패")
                    print("DEBUG: faild connection \(error.localizedDescription)")
                }
            }
    }
    
    func getSearchVideoList(_ subject: Int, _ grade: String, _ sort_id: Int, _ keyword: String, _ offset: Int, _ limit: Int, _ viewController: VideoPlaylistVC) {
        // URL을 구성한다.
        let strSubject = subject == 0 ? "" : "\(subject)"
        let url = apiBaseURL + "/v/search/searchbar"
        
        AF.upload(multipartFormData: { formData in
            
            formData.append("\(strSubject)".data(using: .utf8) ?? Data(), withName: "subject")
            formData.append("\(grade)".data(using: .utf8) ?? Data(), withName: "grade")
            formData.append("\(keyword)".data(using: .utf8) ?? Data(), withName: "keyword")
            formData.append("\(offset)".data(using: .utf8) ?? Data(), withName: "offset")
            formData.append("\(sort_id)".data(using: .utf8) ?? Data(), withName: "sort_id")
            formData.append("\(limit)".data(using: .utf8) ?? Data(), withName: "limit")

        }, to: url)
        
        .responseDecodable(of: VideolistResponse.self) { response in
            switch response.result {
            case .success(let response):
                viewController.didSuccessAddVideolistInAutoplaying(response)
            case .failure(let error):
                print("DEBUG: 재생목록 API 통신 실패")
                print("DEBUG: faild connection \(error.localizedDescription)")
            }
        }
        
//        var param: Parameters = [ "sort_id": sort_id,
//                                  "offset": offset,
//                                  "limit": limit]
//        if subject != 0 {
//            param["subject"] = subject
//        }
//        if grade != "" {
//            param["grade"] = grade
//        }
//        if keyword != "" {
//            param["keyword"] = keyword
//        }
//
//        // POST
//        AF.request(url, method: .post, parameters: param, encoding: JSONEncoding.default, headers: nil)
//            // API에서 성공했을 시, 아무 응답이 없고 실패했을 시 DB Error Log를 호출한다.
//            // 그러므로 Response에 대한 Decoding 전략은 작성하지 않았다. (정확히 말하면 필요가 없음)
//            .responseDecodable(of: VideolistResponse.self) { response in
//
//                switch response.result {
//                case .success(let response):
//                    viewController.didSuccessAddVideolistInAutoplaying(response)
//
//                case .failure(let error):
//                    print("DEBUG: 재생목록 API 통신 실패")
//                    print("DEBUG: faild connection \(error.localizedDescription)")
//                }
//            }
    }
    
    func getSeriesNowPosition(_ seriesId: String, _ videoId: String, viewController: VideoPlaylistVC) {
        // URL을 구성한다.
        let url = apiBaseURL + "/v/video/rownum?series_id=\(seriesId)&video_id=\(videoId)"
        
        /// HTTP Method: GET
        AF.request(url)
            .responseDecodable(of: SeriesVideoPosition.self) { response in
                
                switch response.result {
                case .success(let response):
                    viewController.didSuccessGetVideoPosition(response)
                    
                case .failure(let error):
                    print("DEBUG: 재생목록 API 통신 실패")
                    print("DEBUG: faild connection \(error.localizedDescription)")
                }
            }
    }
    
    func getVideoPlaylistDataFromAPI(_ parameters: VideoPlaylistInput, viewController: VideoPlaylistVC) {
        
        // viewModel -> paramters 를 통해 값을 전달한다.
        let data = parameters
        
        // URL을 구성한다.
        let url = apiBaseURL + "/v/video/serieslist?series_id=\(data.seriesID)&offset=\(data.offset)&limit=\(data.limit)"
        
        /// HTTP Method: GET
        AF.request(url)
            .responseDecodable(of: VideoPlaylistResponse.self) { response in
                
                switch response.result {
                case .success(let response):
                    viewController.didSuccessGetPlaylistData(response)
                    
                case .failure(let error):
                    print("DEBUG: 재생목록 API 통신 실패")
                    print("DEBUG: faild connection \(error.localizedDescription)")
                }
            }
    }
    
    /*func addVideolistInAutoplaying(baseURL: String,
                                   _ viewController: VideoPlaylistVC) { //국영수, 과학,사회,기타만 해당, 그럼 다른것은?
        
        // viewModel -> paramters 를 통해 값을 전달한다.
//        let data = parameters
        let autoplayDM = AutoplayDataManager.shared

        // dummy data
        var sortedId = 4
        switch autoplayDM.currentSort {
        case 0:
            sortedId = 4
        case 1:
            sortedId = 3
        case 2:
            sortedId = 1
        case 3:
            sortedId = 2
        default:
            sortedId = 4
        }
        
        let selectedItem = autoplayDM.currentFiltering == "문제풀이" ? 1 : 0
        
        
        // URL을 구성한다.
        guard let url = URL(string: baseURL + "offset=\(autoplayDM.videoDataList.count)&limit=20&sortId=\(selectedItem == 1 ? 2 : sortedId)&type=\(selectedItem)") else { return }
        
        /// HTTP Method: GET
        AF.request(url)
            .responseDecodable(of: VideoInput.self) { response in
                
                switch response.result {
                case .success(let response):
                    print("DEBUG: 무한스크롤 API 성공")
                    viewController.didSuccessAddVideolistInAutoplaying(response)
                    
                case .failure(let error):
                    print("DEBUG: 재생목록 API 통신 실패")
                    print("DEBUG: faild connection \(error.localizedDescription)")
                }
            }
    }*/
    
    func getVideoPlaylistDataFromAPIInNote(_ parameters: VideoPlaylistInput, viewController: LessonNoteViewModel) {
        
        // viewModel -> paramters 를 통해 값을 전달한다.
        let data = parameters
        
        // URL을 구성한다.
        let url = apiBaseURL + "/v/video/serieslist?series_id=\(data.seriesID)&offset=\(data.offset)"
        
        /// HTTP Method: GET
        AF.request(url)
            .responseDecodable(of: VideoPlaylistResponse.self) { response in
                
                switch response.result {
                case .success(let response):
                    viewController.didSuccessAPI(response: response)
                    print("DEBUG: 시리즈해당 VideoID가져오기 성공")
                    
                case .failure(let error):
                    print("DEBUG: 시리즈해당 VideoID가져오기 실패")
                    print("DEBUG: faild connection \(error.localizedDescription)")
                }
            }
    }
}
