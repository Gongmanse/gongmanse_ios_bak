//
//  SearchVideoViewModel.swift
//  gongmanse
//
//  Created by 김우성 on 2021/03/11.
//

import Foundation
import UIKit

//struct SearchVideoViewModel {
//
//    let search: Search
//
//    var title: String {
//        return search.title
//    }
//
//    var writer: String {
//        return search.writer
//    }
//
//
//    // TODO: Rating, Tag 구현해야함.
//
//    init(search : Search) {
//        self.search = search
//    }
//}

class SearchVideoViewModel {
    
    weak var reloadDelegate: CollectionReloadData?
    
    // API 성공 시 데이터 받을 곳
    var responseVideoModel: SearchVideoModel? = nil
    
    func requestVideoAPI(subject: String?,
                         grade: String?,
                         keyword: String?,
                         offset: String?,
                         sortid: String?,
                         limit: String?) {
        
        let postModel = SearchVideoPostModel(subject: subject,
                                             grade: grade,
                                             keyword: keyword,
                                             offset: offset,
                                             sortid: sortid,
                                             limit: limit)
        
        let videoAPI = SearchAfterVideoAPIManager()
        videoAPI.fetchVideoAPI(postModel) { [weak self] result in
            switch result {
            case .success(let data):
                self?.responseVideoModel = data
                self?.reloadDelegate?.reloadCollection()
                
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}
