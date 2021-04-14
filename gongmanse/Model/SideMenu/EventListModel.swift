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

}
