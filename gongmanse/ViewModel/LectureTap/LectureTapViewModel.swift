//
//  LectureTapViewModel.swift
//  gongmanse
//
//  Created by wallter on 2021/05/17.
//

import UIKit

class LectureTapViewModel {
    
    
    var lectureList: LectureModel?
    var reloadDelgate: CollectionReloadData?
    
    var lectureSeries: LectureSeriesModel?
    
    var isMoreList: Bool = true
    
    
    func lectureListGetApi(grade: String, offset: String) {
        let lectureApiManager = LectureAPIManager(grade, offset)
        
        if isMoreList == false {
            return
        }
        
        if offset == "0" {
            lectureApiManager.initializeApi { response in
                switch response {
                case .success(let data):
                    self.lectureList = data
                    self.reloadDelgate?.reloadCollection()
                case .failure(let err):
                    print(err.localizedDescription)
                }
            }
        } else {
            lectureApiManager.initializeApi { response in
                switch response {
                case .success(let data):
                    
                    if data.data.count == 0 {
                        self.isMoreList = false
                    }
                    
                    for i in 0..<data.data.count {
                        self.lectureList?.data.append(data.data[i])
                    }
                    
                    self.reloadDelgate?.reloadCollection()
                case .failure(let err):
                    print(err.localizedDescription)
                }
            }
        }
        
    }
    
    // 강사별 강의
    func lectureSeriesApi(_ seriesID: String) {
        
        var seriesUrl = "\(apiBaseURL)/v/video/byteacher_series?instructor_id=\(seriesID)&offset=0&limit=20"
        
        
        getAlamofireGeneric(url: &seriesUrl, isConvertUrl: false) { (response: Result<LectureSeriesModel, InfoError>) in
            switch response {
            case .success(let data):
                self.lectureSeries = data
                self.reloadDelgate?.reloadCollection()
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
