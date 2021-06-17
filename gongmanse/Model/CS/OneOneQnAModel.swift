//
//  OneOneQnAModel.swift
//  gongmanse
//
//  Created by wallter on 2021/06/16.
//

import Foundation

// 1:1문의 목록 조회 GET
struct OneOneQnAList: Codable {
    let data: [OneOneQnADataList]
}

struct OneOneQnADataList: Codable {
    let id: String
    let iType: String
    let sQuestion: String
    let sQdatecreated: String
    let sAnswer: String?
    let sStatus: String
    let sAdatecreated: String?
    
    var typeConvert: String {
        switch iType {
        case "1":
            return "이용방법"
        case "2":
            return "서비스 장애"
        case "3":
            return "결제 및 인증"
        case "4":
            return "기타문의"
        case "5":
            return "강의요청"
        default:
            return "오류"
        }
    }
    
    var answerStates: String {
        switch sStatus {
        case "true":
            return "답변완료>"
        case "false":
            return "대기중>"
        default:
            return "오류"
        }
    }
    
    
    var dateConvert: String {
        let dateformatter: DateFormatter = DateFormatter()
        dateformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let stringformatter: DateFormatter = DateFormatter()
        stringformatter.dateFormat = "yyyy-MM-dd"
        
        guard let convertDate = dateformatter.date(from: sQdatecreated) else { return ""}
        
        return stringformatter.string(from: convertDate)
    }
}

// 1:1문의 등록 POST
struct OneOneQnARegist: Codable {
    let token: String
    let question: String
    let type: String
}

// 1:1문의 수정 PATCH


// 1:1문의 삭제 POST
struct OneOneQnADelete: Codable {
    let id: String
}
