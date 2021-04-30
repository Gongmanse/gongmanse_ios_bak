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
    
    static let searchGradeNoti = Notification.Name(NotificationKey.searchGradeKey)
    static let searchSubjectNoti = Notification.Name(NotificationKey.searchSubjectkey)
    static let searchAllNoti = Notification.Name(NotificationKey.searchAllPassKey)
}

struct NotificationKey {
    static let getGradeKey = "getGrade"
    static let getSubjectKey = "getSubject"
    // searchVC 관련
    static let searchGradeKey = "searchGrade"
    static let searchSubjectkey = "searchSubject"
    static let searchAllPassKey = "searchPass"
}
