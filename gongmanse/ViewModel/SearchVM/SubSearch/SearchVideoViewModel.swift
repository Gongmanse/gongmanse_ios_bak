//
//  SearchVideoViewModel.swift
//  gongmanse
//
//  Created by 김우성 on 2021/03/11.
//

import Foundation
import UIKit


class SearchVideoViewModel: SearchInfinityScroll {
    
    // infiniteScroll Protocol
    var infinityBool = false
    
    var allIntiniteScroll = true
    
    var listCount = 0
    //
    
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
        
        var offsetTrans = offset
        
        if infinityBool {
            listCount += 20
            offsetTrans = "\(listCount)"
        }
        
        let postModel = SearchVideoPostModel(subject: subject,
                                             grade: grade,
                                             keyword: keyword,
                                             offset: offsetTrans,
                                             sortid: sortid,
                                             limit: limit)
        
       print(postModel)
        
        let videoAPI = SearchAfterVideoAPIManager()
        videoAPI.fetchVideoAPI(postModel) { [weak self] result in
            switch result {
            case .success(let data):
                
                if self?.infinityBool == true {
                    
                    if data.data.count == 0{
                        self?.allIntiniteScroll = false
                    }
                    
                    for i in 0..<data.data.count {
                        self?.responseVideoModel?.data.append(data.data[i])
                    }
                    self?.reloadDelegate?.reloadCollection()

                }else {
                    self?.responseVideoModel = data
                    self?.reloadDelegate?.reloadCollection()
                }

                
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
}
