//
//  LectureDetailViewModel.swift
//  gongmanse
//
//  Created by wallter on 2021/05/24.
//

import UIKit
import Alamofire

class LectureDetailViewModel {
    
    // 강사별 강의
    var lectureDetail: SeriesDetailModel?
    
    // 관련시리즈
    var relationSeriesList: RelationSeriesModel?
        
        
    var delegate: CollectionReloadData?
    
    var isMoreList: Bool = true
    
    // 강사별 강의
    func lectureDetailApi(_ seriesID: String, offset: Int) {
        
        var detailUrl = "\(apiBaseURL)/v/video/serieslist?series_id=\(seriesID)&offset=\(offset)"
        print(detailUrl)
        
        if isMoreList == false {
            return 
        }
        
        if offset == 0 {
            
            AF.request(detailUrl, method: .get)
                .responseDecodable(of: SeriesDetailModel.self) { (response) in
                    switch response.result {
                    case .success(let data):
                        print(data)
                        self.lectureDetail = data
                        self.delegate?.reloadCollection()
                    case .failure(let err):
                        print(err.localizedDescription)
                    }
                }
            
//            getAlamofireGeneric(url: &detailUrl, isConvertUrl: false) { (response: Result<SeriesDetailModel, InfoError>) in
//                switch response {
//                case .success(let data):
//                    self.lectureDetail = data
//                    self.delegate?.reloadCollection()
//                case .failure(let err):
//                    print(err.localizedDescription)
//                }
//            }
        } else {
            getAlamofireGeneric(url: &detailUrl, isConvertUrl: false) { (response: Result<SeriesDetailModel, InfoError>) in
                switch response {
                case .success(let data):
                    
                    if data.data.count == 0 {
                        self.isMoreList = false
                    }
                    
                    
                    for i in 0..<data.data.count {
                        self.lectureDetail?.data.append(data.data[i])
                    }
                    
                    self.delegate?.reloadCollection()
                case .failure(let err):
                    print(err.localizedDescription)
                }
            }
        }
        
    }
    
    // 관련 시리즈
    func relationSeries(_ videoID: String, offset: Int) {
        
        var relationUrl = "\(apiBaseURL)/v/video/relatives?video_id=\(videoID)&offset=\(offset)"
        print(relationUrl)
        if isMoreList == false {
            return
        }
        
        if offset == 0 {
            
            AF.request(relationUrl, method: .get)
                .responseDecodable(of: RelationSeriesModel.self) { (response) in
                    switch response.result {
                    case .success(let data):
                        self.relationSeriesList = data
                        self.delegate?.reloadCollection()
                    case .failure(let err):
                        print(err.localizedDescription)
                    }
                }
            
//            getAlamofireGeneric(url: &relationUrl, isConvertUrl: false) { (response: Result<RelationSeriesModel, InfoError>) in
//                switch response {
//                case .success(let data):
//
//                    self.relationSeriesList = data
//                    self.delegate?.reloadCollection()
//                case .failure(let err):
//                    print(err.localizedDescription)
//                }
//            }
        } else {
            getAlamofireGeneric(url: &relationUrl, isConvertUrl: false) { (response: Result<RelationSeriesModel, InfoError>) in
                switch response {
                case .success(let data):
                    
                    if data.data.count == 0 {
                        self.isMoreList = false
                    }
                    for i in 0..<data.data.count {
                        self.relationSeriesList?.data.append(data.data[i])
                    }
                    
                    self.delegate?.reloadCollection()
                case .failure(let err):
                    print(err.localizedDescription)
                }
            }
        }
    }
    
    // Grade
    
    func convertGrade(_ grade: String?) -> String{
        
        switch grade {
        case "초등":
            return OneGrade.element.oneWord
        case "중등":
            return OneGrade.middle.oneWord
        case "고등":
            return OneGrade.high.oneWord
        default:
            return ""
        }
    }
    
}
