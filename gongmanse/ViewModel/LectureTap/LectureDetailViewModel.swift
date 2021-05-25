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
    
    // 강사별 강의
    func lectureDetailApi(_ seriesID: String) {
        
        var detailUrl = "\(apiBaseURL)/v/video/serieslist?series_id=\(seriesID)&offset=0"
        
        getAlamofireGeneric(url: &detailUrl, isConvertUrl: false) { (response: Result<SeriesDetailModel, InfoError>) in
            switch response {
            case .success(let data):
                self.lectureDetail = data
                self.delegate?.reloadCollection()
            case .failure(let err):
                print(err.localizedDescription)
            }
        }
    }
    
    // 관련 시리즈
    func relationSeries(_ videoID: String) {
        
        var relationUrl = "\(apiBaseURL)/v/video/relatives?video_id=\(videoID)"
        
        getAlamofireGeneric(url: &relationUrl, isConvertUrl: false) { (response: Result<RelationSeriesModel, InfoError>) in
            switch response {
            case .success(let data):
                self.relationSeriesList = data
                self.delegate?.reloadCollection()
            case .failure(let err):
                print(err.localizedDescription)
            }
        }
    }
    
    // Grade
    
    func convertGrade(_ grade: String?) -> String{
        
        switch grade {
        case "초등":
            return OneGrade.element.oneWord
        case "중등":
            return OneGrade.element.oneWord
        case "고등":
            return OneGrade.element.oneWord
        default:
            return ""
        }
    }
    
}
