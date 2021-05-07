//
//  NotificationName.swift
//  gongmanse
//
//  Created by wallter on 2021/04/21.
//

import Foundation

extension Notification.Name {
    
    // 진도학습
    static let getGrade = Notification.Name(NotificationKey.getGradeKey)
    static let getSubject = Notification.Name(NotificationKey.getSubjectKey)
    
    // 검색 (전)
    static let searchGradeNoti = Notification.Name(NotificationKey.searchGradeKey)
    static let searchSubjectNoti = Notification.Name(NotificationKey.searchSubjectkey)
    static let searchAllNoti = Notification.Name(NotificationKey.searchAllPassKey)
    
    // 검색 (후)
    static let searchAfterVideoNoti = Notification.Name(NotificationKey.searchAfterVideoSort)
    static let searchAfterConsultationNoti = Notification.Name(NotificationKey.searchAfterConsultationSort)
    static let searchAfterNotesNoti = Notification.Name(NotificationKey.searchAfterNotesSort)
    
    // 검색 후 다시 검색
    static let searchAfterSearchNoti = Notification.Name(NotificationKey.searchAfterSearch)
    
}

struct NotificationKey {
    static let getGradeKey = "getGrade"
    static let getSubjectKey = "getSubject"
    // searchVC 관련
    static let searchGradeKey = "searchGrade"
    static let searchSubjectkey = "searchSubject"
    static let searchAllPassKey = "searchPass"
    
    // searchAfter 관련
    static let searchAfterVideoSort = "videoSort"
    static let searchAfterConsultationSort = "consultationSort"
    static let searchAfterNotesSort = "videoNotesSort"
    
    // SearchAter 검색
    static let searchAfterSearch = "reSearch"
}
