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
    var infinityBool = true
    
    var allIntiniteScroll = true
    
    var listCount = 0
    //
    
    weak var reloadDelegate: CollectionReloadData?
    
    // API 성공 시 데이터 받을 곳
    var responseVideoModel: SearchVideoModel? = nil
    
    var offsetTrans: String?
    
    // API 통신
    func requestVideoAPI(subject: String?,
                         grade: String?,
                         keyword: String?,
                         offset: String?,
                         sortid: String?,
                         limit: String?) {
        
        offsetTrans = offset
        
        if offsetTrans == "" {
            if infinityBool {
                listCount += 20
                offsetTrans = "\(listCount)"
            }
        } else if offsetTrans == "0" {
            infinityBool = true
            listCount = 0
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
                
                if self?.offsetTrans != "0" {
                    
                    if data.data.count == 0{
                        self?.infinityBool = false
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
