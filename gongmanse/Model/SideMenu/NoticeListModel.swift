//
//  NoticeListModel.swift
//  gongmanse
//
//  Created by taeuk on 2021/04/05.
//

import UIKit

struct NoticeListModel: Codable {
    let data: [NoticeList]
}

struct NoticeList: Codable {
    
    let id: String
    let sTitle: String
    let sContent: String
    let dtDateCreated: String
    let iViews: String
    
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
