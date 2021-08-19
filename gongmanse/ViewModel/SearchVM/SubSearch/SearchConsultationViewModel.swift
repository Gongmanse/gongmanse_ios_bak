//
//  SearchConsultationViewModel.swift
//  gongmanse
//
//  Created by wallter on 2021/05/06.
//

import UIKit

class SearchConsultationViewModel {
    
    weak var reloadDelegate: CollectionReloadData?
    
    var responseDataModel: SearchConsultationModel? = nil
    var isLoading = false
    
    func requestConsultationApi(keyword: String?, sortId: String?, offset: String?) {
        isLoading = true
        
        let postModel = SearchConsultationPostModel(keyword: keyword, sortID: sortId, offset: offset)
        
        let apiModel = SearchAfterConsultationAPIManager()
        
        apiModel.fetchConsultaionAPI(postModel) { [weak self] response in
            self?.isLoading = false
            
            switch response{
            case .success(let data):
                if offset == "0" {
                    self?.responseDataModel = data
                } else {
                    self?.responseDataModel?.data.append(contentsOf: data.data)
                }
                self?.reloadDelegate?.reloadCollection()
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    
    func answerState(state: String) -> Bool {
        return state == "1" ? true : false
    }
}
