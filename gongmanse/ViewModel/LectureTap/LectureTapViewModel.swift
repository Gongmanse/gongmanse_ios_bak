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
    
    func lectureListGetApi(grade: String, offset: String) {
        let lectureApiManager = LectureAPIManager(grade, offset)
        
        lectureApiManager.initializeApi { response in
            switch response {
            case .success(let data):
                self.lectureList = data
                self.reloadDelgate?.reloadCollection()
            case .failure(let err):
                print(err.localizedDescription)
            }
        }
    }
    
    // 강사별 강의
    func lectureSeriesApi(_ seriesID: String) {
        
        var seriesUrl = "\(apiBaseURL)/v/video/byteacher_series?instructor_id=\(seriesID)&offset=0&limit=20"
        
        getAlamofireGeneric(url: &seriesUrl, isConvertUrl: false) { (response: LectureSeriesModel) in
            self.lectureSeries = response
            print(response.data)
        }
    }
    
}
