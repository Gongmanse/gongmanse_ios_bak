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
    
    func requestConsultationApi(keyword: String, sortId: String) {
        
        let postModel = SearchConsultationPostModel(keyword: keyword, sortID: sortId)
        
        let apiModel = SearchAfterConsultationAPIManager()
        
        apiModel.fetchConsultaionAPI(postModel) { [weak self] response in
            switch response{
            case .success(let data):
                
                self?.responseDataModel = data
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
