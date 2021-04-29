//
//  SearchSingleton.swift
//  gongmanse
//
//  Created by wallter on 2021/04/29.
//

import Foundation

class SearchSingleton {
    static let shared: SearchSingleton = SearchSingleton()
    
    private init() {}
    
    // 검색
    var searchGradeText: String?
    var searchSubjectText: String?
}
