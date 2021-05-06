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


class SearchVideoViewModel: NSAttributedStringColor {
    
    
    
    weak var reloadDelegate: CollectionReloadData?
    
    // API 성공 시 데이터 받을 곳
    var responseVideoModel: SearchVideoModel? = nil
    
    // API 통신
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
                print("data", data.data[0].sTitle)
                self?.responseVideoModel = data
                self?.reloadDelegate?.reloadCollection()
                
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func convertStringColor(_ mainString: String, _ subString: String) -> NSAttributedString{
        let range = (mainString as NSString).range(of: subString)
        
        let mutableString = NSMutableAttributedString.init(string: mainString)
        mutableString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.mainOrange, range: range)
        
        return mutableString
    }
}
