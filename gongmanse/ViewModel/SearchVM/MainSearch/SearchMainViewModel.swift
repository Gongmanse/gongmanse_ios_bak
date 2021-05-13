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
    
    func convertGrade() -> String? {
        
        guard let gradeText = UserDefaults.standard.object(forKey: "gradeFilterText") as? String else { return ""}
        
        
        if gradeText.contains("초등") {
            return Grade.element.convertGrade
        } else if gradeText.contains("중학") {
            return Grade.middle.convertGrade
        } else if gradeText.contains("고등") {
            return Grade.high.convertGrade
        } else {
            return Grade.all.convertGrade
        }
    }
    
    func convertSubject() -> String? {
        guard let subjectText = UserDefaults.standard.object(forKey: "subjectFilterText") as? String else { return ""}
        
        return subjectText
    }
    
}
