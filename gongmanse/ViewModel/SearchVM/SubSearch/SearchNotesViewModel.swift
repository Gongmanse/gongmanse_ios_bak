//
//  SearchNotesViewModel.swift
//  gongmanse
//
//  Created by wallter on 2021/05/06.
//

import UIKit

class SearchNotesViewModel: SearchInfinityScroll {
    
    // infinityScroll
    var infinityBool: Bool = false
    
    var allIntiniteScroll: Bool = true
    
    var listCount: Int = 0
    //
    
    weak var reloadDelegate: CollectionReloadData?
    
    var searchNotesDataModel: SearchNotesModel? = nil
    
    func reqeustNotesApi(subject: String?, grade: String?, keyword: String?, offset: String?, sortID: String?) {
        
        
        
        var offsetTrans = offset
        
        if infinityBool {
            listCount += 20
            offsetTrans = "\(listCount)"
        }
        
        let postModel = SearchNotesPostModel(subject: subject,
                                             grade: grade,
                                             keyword: keyword,
                                             offset: offsetTrans,
                                             sortID: sortID)
        
        let notesAPI = SearchAfterNotesAPIManager()
        notesAPI.fetchNotesAPI(postModel) { [weak self] response in
            switch response {
            case .success(let data):
                
                if self?.infinityBool == true {
                    
                    if data.data.count == 0{
                        self?.allIntiniteScroll = false
                    }
                    
                    for i in 0..<data.data.count {
                        self?.searchNotesDataModel?.data.append(data.data[i])
                    }
                    self?.reloadDelegate?.reloadCollection()

                }else {
                    self?.searchNotesDataModel = data
                    self?.reloadDelegate?.reloadCollection()
                }
                

            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
}
