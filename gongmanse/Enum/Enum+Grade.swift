//
//  Enum+Grade.swift
//  gongmanse
//
//  Created by wallter on 2021/05/13.
//

import Foundation

// MARK: 초등 중등 고등 모든 값이 필요할 때
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

// MARK: 초 중 고 한 단어만 필요할 때

enum OneGrade {
    case element, middle, high
    
    var oneWord: String {
        switch self {
        case .element:
            return "초"
        case .middle:
            return "중"
        case .high:
            return "고"
        }
    }
}
