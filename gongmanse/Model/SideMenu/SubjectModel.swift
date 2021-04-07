//
//  SubjectModel.swift
//  gongmanse
//
//  Created by wallter on 2021/04/07.
//

import Foundation

struct SubjectListModel: Codable {
    
    let data: [SubjectModel]
    
}

struct SubjectModel: Codable {
    let id: String
    let sName: String
}
