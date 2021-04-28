//
//  Search.swift
//  gongmanse
//
//  Created by 김우성 on 2021/03/11.
//

import Foundation

struct Search {
    let title: String
    let writer: String
}

// Dummy Data
let searchs = [
    Search(title: "피타고라스의 정리", writer: "피타고라스"),
    Search(title: "제논의 역설", writer: "제논"),
    Search(title: "하브루타", writer: "탈무드"),
    Search(title: "학익진", writer: "이순신"),
    Search(title: "베르누이의 정리", writer: "베르누이"),
    Search(title: "정언명령", writer: "임마누엘 칸트"),
    Search(title: "공리주의", writer: "제러미 벤담"),
    Search(title: "지행합일설", writer: "아리스토텔레스"),
    Search(title: "상도", writer: "임상옥"),
    Search(title: "상상더하기", writer: "라붐")
]

// 인기 검색어 
struct PopularKeywordModel: Codable {
    let dtLastUpdated: String
    let data: [PopularKeywordDataModel]
}

struct PopularKeywordDataModel: Codable {
    let id: Int
    let keywords: String
}
