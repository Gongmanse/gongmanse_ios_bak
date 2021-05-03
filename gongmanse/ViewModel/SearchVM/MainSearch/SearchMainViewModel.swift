//
//  SearchMainViewModel.swift
//  gongmanse
//
//  Created by wallter on 2021/04/28.
//

import UIKit
// 아직 미완
class SearchMainViewModel {
    
    var delegate: PopularReloadData?
    
    lazy var subjecModel: [SubjectModel] = []
    
    func subjectAPIManager() {
        let getSubject = getSubjectAPI()
        getSubject.performSubjectAPI { [weak self] result in
            self?.subjecModel = result
            self?.delegate?.reloadData()
        }
    }
    
    
}
