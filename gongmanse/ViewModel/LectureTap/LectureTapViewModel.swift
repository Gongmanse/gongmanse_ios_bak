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
    
}
