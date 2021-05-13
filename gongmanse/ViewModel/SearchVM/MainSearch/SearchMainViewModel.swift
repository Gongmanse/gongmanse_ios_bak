//
//  SearchMainViewModel.swift
//  gongmanse
//
//  Created by wallter on 2021/04/28.
//


import UIKit
// 아직 미완
class SearchMainViewModel {
    
    var delegate: TableReloadData?
    
    lazy var subjecModel: [SubjectModel] = []
    
    func subjectAPIManager() {
        let getSubject = getSubjectAPI()
        getSubject.performSubjectAPI { [weak self] result in
            self?.subjecModel = result
            self?.delegate?.reloadTable()
        }
    }
    
    // 초등학교 1학년 -> 초등
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
        return UserDefaults.standard.object(forKey: "subjectFilterText") as? String
    }
    
}
