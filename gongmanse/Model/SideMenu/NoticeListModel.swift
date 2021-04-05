//
//  NoticeListModel.swift
//  gongmanse
//
//  Created by taeuk on 2021/04/05.
//

import Foundation

struct NoticeListModel: Codable {
    let data: [NoticeList]
}

struct NoticeList: Codable {
    
    let id: String
    let sTitle: String
    let sContent: String
    let dtDateCreated: String
    let iViews: String
}
