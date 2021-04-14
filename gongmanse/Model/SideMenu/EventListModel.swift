//
//  EventListModel.swift
//  gongmanse
//
//  Created by wallter on 2021/04/14.
//

import Foundation

struct EventListModel: Codable {
    let data: [EventModel]
}

struct EventModel: Codable {
    
    let id: String
    let eType: String
    let sStatus: String
    let dtDateCreated: String
    let sTitle: String
    let sDescription: String
    let iViews: String
    let sThumbnail: String

    
    var viewer: String {
        return "조회수 \(iViews)"
    }
    
    var dateViewer: String {
        let dateGet = DateFormatter()
        dateGet.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let datePrint = DateFormatter()
        datePrint.dateFormat = "yyyy.MM.dd"
        let beforeDate = dateGet.date(from: dtDateCreated)
        let afterDate = datePrint.string(from: beforeDate ?? Date())
        return afterDate
    }
    
}
