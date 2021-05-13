//
//  Enum+Grade.swift
//  gongmanse
//
//  Created by wallter on 2021/05/13.
//

import Foundation

enum Grade {
    case element
    case middle
    case high
    case all
    
    var convertGrade: String? {
        switch self {
        case .element:
            return "초등"
        case .middle:
            return "중등"
        case .high:
            return "고등"
        case .all:
            return nil
        }
        
    }
}
