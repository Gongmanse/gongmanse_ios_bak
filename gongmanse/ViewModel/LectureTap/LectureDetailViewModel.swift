//
//  LectureDetailViewModel.swift
//  gongmanse
//
//  Created by wallter on 2021/05/24.
//

import UIKit
import Alamofire

class LectureDetailViewModel {
    
    var lectureDetail: SeriesDetailModel?
    
    var delegate: CollectionReloadData?
    
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
